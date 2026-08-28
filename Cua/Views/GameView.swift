import SwiftUI
import SpriteKit

struct GameView: View {
    let levelIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    @State private var scene: CrabHuntingGameScene = {
        let sc = CrabHuntingGameScene(size: CGSize(width: 380, height: 500))
        sc.scaleMode = .aspectFit
        return sc
    }()
    
    @State private var score: Int = 0
    @State private var combo: Int = 0
    @State private var isPaused: Bool = false
    @State private var isLevelCompleted: Bool = false
    @State private var isGameOver: Bool = false
    @State private var activeLevelIndex: Int = 0
    
    @AppStorage("cua_high_score") private var highScore: Int = 0
    @AppStorage("cua_unlocked_level") private var unlockedLevel: Int = 1
    
    var currentConfig: GameLevelConfig {
        if activeLevelIndex < gameLevels.count {
            return gameLevels[activeLevelIndex]
        }
        return gameLevels.last!
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.04, green: 0.08, blue: 0.18)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top HUD
                gameHUD
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                // SpriteKit Game View
                SpriteView(scene: scene)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                
                // Bottom Tap Action Panel
                bottomActionPanel
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
            }
            
            // Level Completed Overlay
            if isLevelCompleted {
                levelCompletedOverlay
            }
            
            // Pause Overlay
            if isPaused {
                pauseOverlay
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            activeLevelIndex = levelIndex
            setupSceneCallbacks()
            scene.startLevel(activeLevelIndex)
        }
    }
    
    // MARK: - Top HUD
    private var gameHUD: some View {
        VStack(spacing: 8) {
            HStack {
                Button {
                    isPaused = true
                    scene.togglePause()
                } label: {
                    Image(systemName: "pause.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Level \(currentConfig.level): \(currentConfig.name)")
                        .font(.headline.bold())
                        .foregroundColor(.cyan)
                    Text(currentConfig.description)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Score & Combo
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Text("Điểm:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(score)")
                            .font(.system(.title3, design: .rounded).bold())
                            .foregroundColor(.yellow)
                    }
                    
                    if combo > 1 {
                        Text("🔥 Combo x\(combo)")
                            .font(.caption2.bold())
                            .foregroundColor(.orange)
                            .transition(.scale)
                    }
                }
            }
            
            // Level Target Progress Bar
            VStack(spacing: 4) {
                ProgressView(value: min(1.0, Double(score) / Double(currentConfig.targetScore)))
                    .tint(.orange)
                
                HStack {
                    Text("Mục tiêu: \(currentConfig.targetScore) điểm")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(Int(min(1.0, Double(score) / Double(currentConfig.targetScore)) * 100))%")
                        .font(.caption2.bold())
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .cornerRadius(18)
    }
    
    // MARK: - Bottom Action Panel
    private var bottomActionPanel: some View {
        HStack(spacing: 16) {
            Button {
                scene.triggerTapFromUI()
            } label: {
                HStack(spacing: 10) {
                    Text("🦀")
                        .font(.title)
                    Text("GẮP ỐC NGAY!")
                        .font(.headline.bold())
                    Text("🐚")
                        .font(.title)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)
                )
                .foregroundColor(.white)
                .clipShape(Capsule())
                .shadow(color: .orange.opacity(0.4), radius: 8, x: 0, y: 4)
            }
        }
    }
    
    // MARK: - Overlays
    private var levelCompletedOverlay: some View {
        ZStack {
            Color.black.opacity(0.75).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("🎉")
                    .font(.system(size: 70))
                
                Text("VƯỢT LEVEL \(currentConfig.level)!")
                    .font(.title.bold())
                    .foregroundColor(.yellow)
                
                Text("Chúc mừng bạn đã hoàn thành \(currentConfig.name)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 8) {
                    Text("Điểm đạt được: \(score)")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    
                    if score > highScore {
                        Text("🏆 KỶ LỤC MỚI!")
                            .font(.caption.bold())
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.1))
                .cornerRadius(16)
                
                VStack(spacing: 12) {
                    if activeLevelIndex + 1 < gameLevels.count {
                        Button {
                            isLevelCompleted = false
                            activeLevelIndex += 1
                            if activeLevelIndex + 1 > unlockedLevel {
                                unlockedLevel = activeLevelIndex + 1
                            }
                            scene.startLevel(activeLevelIndex)
                        } label: {
                            Text("Qua Level Kế Tiếp 🚀")
                                .font(.headline.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(14)
                        }
                    }
                    
                    Button {
                        isLevelCompleted = false
                        scene.startLevel(activeLevelIndex)
                    } label: {
                        Text("Chơi Lại Level Này 🔄")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue.opacity(0.6))
                            .cornerRadius(14)
                    }
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Về Menu Chính 🏠")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(28)
            .background(Color(red: 0.08, green: 0.14, blue: 0.28))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal, 28)
        }
    }
    
    private var pauseOverlay: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            
            VStack(spacing: 18) {
                Text("⏸️ Tạm Dừng")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                VStack(spacing: 12) {
                    Button {
                        isPaused = false
                        scene.togglePause()
                    } label: {
                        Text("Tiếp Tục Chơi ▶️")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(14)
                    }
                    
                    Button {
                        isPaused = false
                        scene.startLevel(activeLevelIndex)
                    } label: {
                        Text("Chơi Lại Từ Đầu 🔄")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(14)
                    }
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Thoát Ra Menu 🏠")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(28)
            .background(Color(red: 0.08, green: 0.14, blue: 0.28))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal, 36)
        }
    }
    
    // MARK: - Scene Callbacks
    private func setupSceneCallbacks() {
        scene.onScoreUpdate = { newScore, newCombo in
            self.score = newScore
            self.combo = newCombo
            if newScore > self.highScore {
                self.highScore = newScore
            }
        }
        
        scene.onLevelComplete = { _ in
            self.isLevelCompleted = true
            if self.activeLevelIndex + 2 > self.unlockedLevel && self.activeLevelIndex + 1 < gameLevels.count {
                self.unlockedLevel = self.activeLevelIndex + 2
            }
        }
    }
}
