import SpriteKit
import SwiftUI

// MARK: - Game Level Configuration
struct GameLevelConfig {
    let level: Int
    let name: String
    let targetScore: Int
    let snailsPerSpawn: Int
    let baseSpeed: Double
    let spawnInterval: TimeInterval
    let canChangeDirection: Bool
    let description: String
}

let gameLevels: [GameLevelConfig] = [
    GameLevelConfig(level: 1, name: "Tập Sự", targetScore: 100, snailsPerSpawn: 1, baseSpeed: 1.0, spawnInterval: 2.5, canChangeDirection: false, description: "Làm quen cơ chế gắp ốc"),
    GameLevelConfig(level: 2, name: "Thủy Triều", targetScore: 250, snailsPerSpawn: 2, baseSpeed: 1.4, spawnInterval: 2.0, canChangeDirection: false, description: "Bắt đầu chọn ốc gần nhất"),
    GameLevelConfig(level: 3, name: "Bão Cát", targetScore: 450, snailsPerSpawn: 3, baseSpeed: 1.9, spawnInterval: 1.5, canChangeDirection: false, description: "Tăng mật độ ốc quanh cua"),
    GameLevelConfig(level: 4, name: "Vực Thẳm", targetScore: 700, snailsPerSpawn: 4, baseSpeed: 2.5, spawnInterval: 1.0, canChangeDirection: false, description: "Tốc độ nhanh, cẩn thận kẻo trượt"),
    GameLevelConfig(level: 5, name: "Đại Dương Cuồng Nộ", targetScore: 1000, snailsPerSpawn: 5, baseSpeed: 3.2, spawnInterval: 0.7, canChangeDirection: true, description: "Ốc đổi chiều quay ngẫu nhiên!")
]

// MARK: - Snail Data Model
class SnailNode: SKNode {
    var angle: Double = 0.0 // in radians
    var orbitRadius: CGFloat = 130
    var speedMultiplier: Double = 1.0
    var direction: Double = 1.0 // 1 for clockwise, -1 for counter-clockwise
    var isCaptured: Bool = false
    
    let visualLabel = SKLabelNode(text: "🐚")
    let glowNode = SKShapeNode(circleOfRadius: 18)
    
    init(angle: Double, orbitRadius: CGFloat, speedMultiplier: Double, direction: Double) {
        super.init()
        self.angle = angle
        self.orbitRadius = orbitRadius
        self.speedMultiplier = speedMultiplier
        self.direction = direction
        
        setupVisuals()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupVisuals() {
        glowNode.fillColor = UIColor.systemYellow.withAlphaComponent(0.2)
        glowNode.strokeColor = UIColor.systemOrange.withAlphaComponent(0.6)
        glowNode.lineWidth = 1.5
        addChild(glowNode)
        
        visualLabel.fontSize = 32
        visualLabel.verticalAlignmentMode = .center
        visualLabel.horizontalAlignmentMode = .center
        addChild(visualLabel)
        
        updatePosition()
    }
    
    func updatePosition() {
        let x = orbitRadius * CGFloat(cos(angle))
        let y = orbitRadius * CGFloat(sin(angle))
        self.position = CGPoint(x: x, y: y)
        self.zRotation = CGFloat(angle) - .pi / 2
    }
}

// MARK: - Crab Hunting Game Scene
class CrabHuntingGameScene: SKScene {
    
    // Delegate to communicate with SwiftUI
    var onScoreUpdate: ((Int, Int) -> Void)? // score, combo
    var onLevelComplete: ((Int) -> Void)?
    var onGameOver: ((Int) -> Void)?
    var onLivesUpdate: ((Int) -> Void)?
    
    private var currentLevelIndex: Int = 0
    private var score: Int = 0
    private var combo: Int = 0
    private var lives: Int = 3
    private var isGamePaused: Bool = false
    private var isClawExtending: Bool = false
    
    // Nodes
    private var centerCrabBody: SKLabelNode!
    private var leftClaw: SKLabelNode!
    private var rightClaw: SKLabelNode!
    private var orbitGuideRing: SKShapeNode!
    private var snailsContainer = SKNode()
    
    // Timers & Spawning
    private var lastUpdateTime: TimeInterval = 0
    private var timeSinceLastSpawn: TimeInterval = 0
    private var currentOrbitRadius: CGFloat = 135
    
    var currentLevelConfig: GameLevelConfig {
        if currentLevelIndex < gameLevels.count {
            return gameLevels[currentLevelIndex]
        }
        return gameLevels.last!
    }
    
    func startLevel(_ levelIndex: Int) {
        self.currentLevelIndex = levelIndex
        self.score = 0
        self.combo = 0
        self.lives = 3
        self.isGamePaused = false
        self.isClawExtending = false
        snailsContainer.removeAllChildren()
        
        onScoreUpdate?(score, combo)
        onLivesUpdate?(lives)
    }
    
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor(red: 0.05, green: 0.10, blue: 0.22, alpha: 1.0)
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        setupBackgroundEffects()
        setupOrbitRing()
        setupCrab()
        
        addChild(snailsContainer)
        
        // Spawn initial snails
        spawnSnails(count: currentLevelConfig.snailsPerSpawn)
    }
    
    // MARK: - Visual Setup
    private func setupBackgroundEffects() {
        // Subtle decorative rings
        for r in [80, 135, 190] {
            let ring = SKShapeNode(circleOfRadius: CGFloat(r))
            ring.strokeColor = UIColor.white.withAlphaComponent(0.06)
            ring.lineWidth = 1
            ring.lineDashPattern = [4, 6]
            addChild(ring)
        }
    }
    
    private func setupOrbitRing() {
        orbitGuideRing = SKShapeNode(circleOfRadius: currentOrbitRadius)
        orbitGuideRing.strokeColor = UIColor.systemCyan.withAlphaComponent(0.25)
        orbitGuideRing.lineWidth = 2
        addChild(orbitGuideRing)
    }
    
    private func setupCrab() {
        // Crab Body at center
        centerCrabBody = SKLabelNode(text: "🦀")
        centerCrabBody.fontSize = 68
        centerCrabBody.verticalAlignmentMode = .center
        centerCrabBody.horizontalAlignmentMode = .center
        centerCrabBody.position = .zero
        centerCrabBody.zPosition = 10
        addChild(centerCrabBody)
        
        // Gentle breathing animation for crab
        let scaleUp = SKAction.scale(to: 1.08, duration: 0.8)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.8)
        let breathe = SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown]))
        centerCrabBody.run(breathe)
        
        // Claws
        leftClaw = SKLabelNode(text: "🦞")
        leftClaw.fontSize = 36
        leftClaw.position = CGPoint(x: -28, y: 24)
        leftClaw.zPosition = 9
        addChild(leftClaw)
        
        rightClaw = SKLabelNode(text: "🦞")
        rightClaw.fontSize = 36
        rightClaw.position = CGPoint(x: 28, y: 24)
        rightClaw.xScale = -1.0 // Flip horizontally
        rightClaw.zPosition = 9
        addChild(rightClaw)
    }
    
    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
        guard !isGamePaused else { return }
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }
        
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Update snails orbit
        let rotationDelta = currentLevelConfig.baseSpeed * deltaTime
        
        for node in snailsContainer.children {
            if let snail = node as? SnailNode, !snail.isCaptured {
                snail.angle += rotationDelta * snail.direction
                
                // Keep angle in 0...2pi
                if snail.angle > .pi * 2 {
                    snail.angle -= .pi * 2
                } else if snail.angle < 0 {
                    snail.angle += .pi * 2
                }
                snail.updatePosition()
            }
        }
        
        // Spawning timer
        timeSinceLastSpawn += deltaTime
        if timeSinceLastSpawn >= currentLevelConfig.spawnInterval {
            timeSinceLastSpawn = 0
            if snailsContainer.children.count < currentLevelConfig.snailsPerSpawn + 3 {
                spawnSnails(count: 1)
            }
            
            // Random direction change for level 5
            if currentLevelConfig.canChangeDirection && Bool.random() && Bool.random() {
                toggleRandomSnailDirection()
            }
        }
    }
    
    // MARK: - Snail Spawning
    private func spawnSnails(count: Int) {
        for _ in 0..<count {
            let randomAngle = Double.random(in: 0...(.pi * 2))
            let direction: Double = (currentLevelConfig.canChangeDirection && Bool.random()) ? -1.0 : 1.0
            let snail = SnailNode(
                angle: randomAngle,
                orbitRadius: currentOrbitRadius,
                speedMultiplier: currentLevelConfig.baseSpeed,
                direction: direction
            )
            snail.alpha = 0
            snail.setScale(0.2)
            snailsContainer.addChild(snail)
            
            let appear = SKAction.group([
                SKAction.fadeIn(withDuration: 0.3),
                SKAction.scale(to: 1.0, duration: 0.3)
            ])
            snail.run(appear)
        }
    }
    
    private func toggleRandomSnailDirection() {
        if let randomSnail = snailsContainer.children.randomElement() as? SnailNode {
            randomSnail.direction *= -1.0
            
            // Flash color when changing direction
            let flash = SKAction.sequence([
                SKAction.run { randomSnail.glowNode.fillColor = UIColor.systemPink.withAlphaComponent(0.6) },
                SKAction.wait(forDuration: 0.25),
                SKAction.run { randomSnail.glowNode.fillColor = UIColor.systemYellow.withAlphaComponent(0.2) }
            ])
            randomSnail.run(flash)
        }
    }
    
    // MARK: - Input & Claw Grab Mechanic
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGamePaused else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        attemptGrab(targetLocation: location)
    }
    
    func triggerTapFromUI() {
        attemptGrab(targetLocation: CGPoint(x: 0, y: currentOrbitRadius))
    }
    
    private func attemptGrab(targetLocation: CGPoint) {
        guard !isClawExtending else { return }
        
        // Find the target snail: either closest to tap or closest to 12 o'clock if tapped on crab
        let activeSnails = snailsContainer.children.compactMap { $0 as? SnailNode }.filter { !$0.isCaptured }
        guard !activeSnails.isEmpty else { return }
        
        let targetSnail: SnailNode
        let tapDistanceToCenter = hypot(targetLocation.x, targetLocation.y)
        
        if tapDistanceToCenter < 60 {
            // Tapped on crab center -> target the snail closest to Top (angle pi/2) or any closest angle
            targetSnail = activeSnails.min(by: {
                let diff1 = abs($0.position.y - currentOrbitRadius)
                let diff2 = abs($1.position.y - currentOrbitRadius)
                return diff1 < diff2
            }) ?? activeSnails[0]
        } else {
            // Tapped towards a direction -> pick snail closest to tap angle
            let tapAngle = atan2(targetLocation.y, targetLocation.x)
            targetSnail = activeSnails.min(by: {
                let diff1 = abs(angleDifference(angle1: $0.angle, angle2: Double(tapAngle)))
                let diff2 = abs(angleDifference(angle1: $1.angle, angle2: Double(tapAngle)))
                return diff1 < diff2
            }) ?? activeSnails[0]
        }
        
        launchClawAnimation(towards: targetSnail)
    }
    
    private func angleDifference(angle1: Double, angle2: Double) -> Double {
        var diff = angle1 - angle2
        while diff < -.pi { diff += .pi * 2 }
        while diff > .pi { diff -= .pi * 2 }
        return diff
    }
    
    private func launchClawAnimation(towards snail: SnailNode) {
        isClawExtending = true
        
        // Haptic feedback on throw
        triggerHaptic(style: .light)
        
        // Determine whether to use left or right claw based on angle
        let claw = (snail.position.x >= 0) ? rightClaw! : leftClaw!
        let initialClawPos = claw.position
        let targetPoint = snail.position
        
        // Crab body reacts
        let bodyRecoil = SKAction.sequence([
            SKAction.scale(to: 0.9, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        centerCrabBody.run(bodyRecoil)
        
        // Claw shoots out to snail position
        let reachDuration: TimeInterval = 0.15
        let moveOut = SKAction.move(to: targetPoint, duration: reachDuration)
        moveOut.timingMode = .easeOut
        
        // Claw snap & capture
        let captureAction = SKAction.run { [weak self, weak snail] in
            guard let self = self, let snail = snail, !snail.isCaptured else { return }
            
            snail.isCaptured = true
            self.triggerHaptic(style: .heavy)
            
            // Score calculations
            self.combo += 1
            let pointsEarned = 10 * self.combo
            self.score += pointsEarned
            
            self.onScoreUpdate?(self.score, self.combo)
            self.showFloatingScore(points: pointsEarned, at: targetPoint, combo: self.combo)
            self.createBubbleExplosion(at: targetPoint)
            
            // Attach snail to claw during retraction
            snail.removeFromParent()
            claw.addChild(snail)
            snail.position = CGPoint(x: 0, y: 15)
            
            // Check Level Complete
            if self.score >= self.currentLevelConfig.targetScore {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.onLevelComplete?(self.currentLevelIndex)
                }
            }
        }
        
        // Retract claw back
        let returnDuration: TimeInterval = 0.18
        let moveBack = SKAction.move(to: initialClawPos, duration: returnDuration)
        moveBack.timingMode = .easeIn
        
        let finishAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            claw.removeAllChildren() // Remove captured snail attached to claw
            self.isClawExtending = false
            
            // Replenish snails if low
            if self.snailsContainer.children.count < 2 {
                self.spawnSnails(count: self.currentLevelConfig.snailsPerSpawn)
            }
        }
        
        let sequence = SKAction.sequence([moveOut, captureAction, SKAction.wait(forDuration: 0.04), moveBack, finishAction])
        claw.run(sequence)
    }
    
    // MARK: - Particles & Floating Text
    private func showFloatingScore(points: Int, at position: CGPoint, combo: Int) {
        let label = SKLabelNode(text: combo > 1 ? "+\(points) 🔥x\(combo)" : "+\(points)")
        label.fontSize = combo > 2 ? 24 : 18
        label.fontName = "HelveticaNeue-Bold"
        label.fontColor = combo > 2 ? UIColor.systemYellow : UIColor.white
        label.position = position
        label.zPosition = 50
        addChild(label)
        
        let floatUp = SKAction.moveBy(x: 0, y: 35, duration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let group = SKAction.group([floatUp, fadeOut])
        let remove = SKAction.removeFromParent()
        
        label.run(SKAction.sequence([group, remove]))
    }
    
    private func createBubbleExplosion(at position: CGPoint) {
        for _ in 0..<8 {
            let bubble = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...7))
            bubble.fillColor = UIColor.cyan.withAlphaComponent(0.7)
            bubble.strokeColor = UIColor.white
            bubble.lineWidth = 1
            bubble.position = position
            bubble.zPosition = 30
            addChild(bubble)
            
            let randomX = CGFloat.random(in: -30...30)
            let randomY = CGFloat.random(in: -30...30)
            let spread = SKAction.moveBy(x: randomX, y: randomY, duration: 0.35)
            let fade = SKAction.fadeOut(withDuration: 0.35)
            let group = SKAction.group([spread, fade])
            let remove = SKAction.removeFromParent()
            
            bubble.run(SKAction.sequence([group, remove]))
        }
    }
    
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
        #endif
    }
    
    func togglePause() {
        isGamePaused.toggle()
    }
}
