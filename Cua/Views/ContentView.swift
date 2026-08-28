import SwiftUI

// MARK: - Models & Data
struct CrabSpecies: Identifiable {
    let id: Int
    let name: String
    let icon: String
    let requiredClicks: Int
    let description: String
    let color: Color
}

let allSpecies: [CrabSpecies] = [
    CrabSpecies(id: 1, name: "Cua Đồng", icon: "🦀", requiredClicks: 0, description: "Chú cua đồng nhỏ nhắn, hay bò ngang ruộng lúa.", color: .orange),
    CrabSpecies(id: 2, name: "Cua Biển", icon: "🦞", requiredClicks: 50, description: "Cua biển lực lưỡng, bơi lội khỏe mạnh giữa đại dương.", color: .red),
    CrabSpecies(id: 3, name: "Cua Huỳnh Đế", icon: "👑", requiredClicks: 200, description: "Vương giả họ Cua với bộ giáp lộng lẫy và đôi càng quyền lực.", color: .purple),
    CrabSpecies(id: 4, name: "Cua Vũ Trụ", icon: "👾", requiredClicks: 600, description: "Cua đến từ hành tinh khác, có năng lực bẻ cong không thời gian!", color: .cyan)
]

struct UpgradeItem: Identifiable {
    let id: String
    let name: String
    let icon: String
    let baseCost: Int
    let multiplier: Int
    let description: String
}

let shopUpgrades: [UpgradeItem] = [
    UpgradeItem(id: "auto_claw", name: "Càng Tự Động", icon: "🦾", baseCost: 30, multiplier: 1, description: "Tự động gắp cua mỗi giây"),
    UpgradeItem(id: "golden_claw", name: "Càng Mạ Vàng", icon: "✨", baseCost: 100, multiplier: 5, description: "Tăng x5 số điểm mỗi lần chạm"),
    UpgradeItem(id: "crab_trap", name: "Lờ Bắt Cua", icon: "🧺", baseCost: 300, multiplier: 15, description: "Tự động thu hoạch cua quy mô lớn")
]

// MARK: - Main ContentView
struct ContentView: View {
    @AppStorage("crab_total_clicks") private var totalClicks: Int = 0
    @AppStorage("crab_pearls") private var pearls: Int = 0
    @AppStorage("auto_claw_count") private var autoClawCount: Int = 0
    @AppStorage("golden_claw_count") private var goldenClawCount: Int = 0
    @AppStorage("crab_trap_count") private var crabTrapCount: Int = 0
    
    @State private var crabScale: CGFloat = 1.0
    @State private var crabRotation: Double = 0.0
    @State private var floatingCrabs: [FloatingParticle] = []
    @State private var activeTab: Int = 0
    @State private var showingInfoSheet = false
    
    // Timer for auto income
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var currentSpecies: CrabSpecies {
        let sorted = allSpecies.sorted { $0.requiredClicks > $1.requiredClicks }
        return sorted.first { totalClicks >= $0.requiredClicks } ?? allSpecies[0]
    }
    
    var clickPower: Int {
        return 1 + (goldenClawCount * 5)
    }
    
    var passiveIncome: Int {
        return (autoClawCount * 1) + (crabTrapCount * 10)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Ocean Background Gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.15, blue: 0.30),
                        Color(red: 0.03, green: 0.08, blue: 0.18)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Bubbles / Background Ambience
                GeometryReader { geo in
                    ForEach(0..<10, id: \.self) { i in
                        Circle()
                            .fill(Color.white.opacity(0.04))
                            .frame(width: CGFloat(20 + (i * 12)), height: CGFloat(20 + (i * 12)))
                            .position(
                                x: CGFloat((i * 45) % Int(geo.size.width)),
                                y: CGFloat((i * 85 + 50) % Int(geo.size.height))
                            )
                    }
                }
                
                VStack(spacing: 0) {
                    // Header Bar
                    headerView
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    // Tab Content
                    TabView(selection: $activeTab) {
                        mainGameView
                            .tag(0)
                        
                        shopView
                            .tag(1)
                        
                        speciesGalleryView
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    // Custom Floating Bottom Navigation
                    bottomNavigationBar
                        .padding(.horizontal, 24)
                        .padding(.bottom, 12)
                }
                
                // Floating tap score particles
                ForEach(floatingCrabs) { particle in
                    Text("+\(particle.value) 🦀")
                        .font(.system(.headline, design: .rounded).bold())
                        .foregroundColor(.yellow)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingInfoSheet) {
                InfoSheetView()
            }
            .onReceive(timer) { _ in
                if passiveIncome > 0 {
                    pearls += passiveIncome
                    totalClicks += passiveIncome
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("App Cua 🦀")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text(currentSpecies.name)
                    .font(.subheadline)
                    .foregroundColor(currentSpecies.color)
                    .bold()
            }
            
            Spacer()
            
            // Pearls Balance
            HStack(spacing: 6) {
                Text("💎")
                Text("\(pearls)")
                    .font(.system(.headline, design: .monospaced).bold())
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            
            Button {
                showingInfoSheet = true
            } label: {
                Image(systemName: "info.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.leading, 4)
        }
    }
    
    // MARK: - Tab 1: Main Game View
    private var mainGameView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Level progress
            VStack(spacing: 8) {
                HStack {
                    Text("Cấp độ tiến hóa")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(totalClicks) Cua đã bắt")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 40)
                
                ProgressView(value: min(1.0, Double(totalClicks) / Double(max(1, nextSpeciesTarget))))
                    .tint(currentSpecies.color)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            // Interactive Crab Mascot
            Button {
                handleCrabTap()
            } label: {
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(currentSpecies.color.opacity(0.25))
                        .frame(width: 220, height: 220)
                        .blur(radius: 20)
                    
                    // Crab Button Surface
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 190, height: 190)
                        .overlay(
                            Circle().stroke(currentSpecies.color.opacity(0.5), lineWidth: 3)
                        )
                        .shadow(color: currentSpecies.color.opacity(0.4), radius: 15, x: 0, y: 8)
                    
                    Text(currentSpecies.icon)
                        .font(.system(size: 90))
                        .scaleEffect(crabScale)
                        .rotationEffect(.degrees(crabRotation))
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("Chạm vào Cua để thu hoạch!")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.6))
            
            Spacer()
            
            // Stats Card
            HStack(spacing: 16) {
                StatCard(title: "Sức mạnh gắp", value: "+\(clickPower)/chạm", icon: "hand.tap.fill", color: .orange)
                StatCard(title: "Tự động", value: "+\(passiveIncome)/giây", icon: "bolt.fill", color: .green)
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
    
    var nextSpeciesTarget: Int {
        let upcoming = allSpecies.first { $0.requiredClicks > totalClicks }
        return upcoming?.requiredClicks ?? totalClicks
    }
    
    // MARK: - Tab 2: Shop View
    private var shopView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Nâng cấp ngư cụ 🛒")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.top, 12)
                
                ForEach(shopUpgrades) { item in
                    let currentCount = countForItem(item.id)
                    let currentCost = item.baseCost * (currentCount + 1)
                    
                    HStack(spacing: 16) {
                        Text(item.icon)
                            .font(.system(size: 40))
                            .frame(width: 54, height: 54)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(item.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("Lv.\(currentCount)")
                                    .font(.caption.bold())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.3))
                                    .cornerRadius(6)
                                    .foregroundColor(.cyan)
                            }
                            
                            Text(item.description)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            HStack {
                                Text("Giá: 💎 \(currentCost)")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.yellow)
                                Spacer()
                                Button {
                                    buyUpgrade(item: item, cost: currentCost)
                                } label: {
                                    Text("Mua")
                                        .font(.caption.bold())
                                        .foregroundColor(pearls >= currentCost ? .white : .gray)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 6)
                                        .background(pearls >= currentCost ? Color.orange : Color.gray.opacity(0.3))
                                        .clipShape(Capsule())
                                }
                                .disabled(pearls < currentCost)
                            }
                        }
                    }
                    .padding(14)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 80)
        }
    }
    
    // MARK: - Tab 3: Species Gallery
    private var speciesGalleryView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Bộ sưu tập loài Cua 📖")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.top, 12)
                
                ForEach(allSpecies) { species in
                    let isUnlocked = totalClicks >= species.requiredClicks
                    
                    HStack(spacing: 16) {
                        Text(isUnlocked ? species.icon : "❓")
                            .font(.system(size: 44))
                            .frame(width: 60, height: 60)
                            .background(isUnlocked ? species.color.opacity(0.2) : Color.gray.opacity(0.2))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(isUnlocked ? species.name : "Chưa mở khóa")
                                    .font(.headline)
                                    .foregroundColor(isUnlocked ? .white : .gray)
                                Spacer()
                                if isUnlocked {
                                    Text("Đã mở")
                                        .font(.caption2.bold())
                                        .foregroundColor(.green)
                                } else {
                                    Text("Cần \(species.requiredClicks) 🦀")
                                        .font(.caption2.bold())
                                        .foregroundColor(.orange)
                                }
                            }
                            
                            Text(isUnlocked ? species.description : "Tiếp tục bắt thêm cua để khám phá loài này.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(14)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isUnlocked ? species.color.opacity(0.3) : Color.white.opacity(0.05), lineWidth: 1)
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 80)
        }
    }
    
    // MARK: - Custom Bottom Navigation
    private var bottomNavigationBar: some View {
        HStack {
            NavButton(icon: "gamecontroller.fill", title: "Bắt Cua", isSelected: activeTab == 0) {
                activeTab = 0
            }
            Spacer()
            NavButton(icon: "cart.fill", title: "Cửa hàng", isSelected: activeTab == 1) {
                activeTab = 1
            }
            Spacer()
            NavButton(icon: "book.closed.fill", title: "Loài Cua", isSelected: activeTab == 2) {
                activeTab = 2
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
    
    // MARK: - Helpers & Actions
    private func handleCrabTap() {
        totalClicks += clickPower
        pearls += clickPower
        
        // Haptic & Animation
        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        #endif
        
        withAnimation(.spring(response: 0.18, dampingFraction: 0.4, blendDuration: 0)) {
            crabScale = 1.25
            crabRotation = Double.random(in: -15...15)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                crabScale = 1.0
                crabRotation = 0.0
            }
        }
        
        // Floating particle effect
        let newParticle = FloatingParticle(
            value: clickPower,
            position: CGPoint(
                x: CGFloat.random(in: 120...240),
                y: CGFloat.random(in: 320...380)
            )
        )
        floatingCrabs.append(newParticle)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if let idx = floatingCrabs.firstIndex(where: { $0.id == newParticle.id }) {
                floatingCrabs.remove(at: idx)
            }
        }
    }
    
    private func countForItem(_ id: String) -> Int {
        switch id {
        case "auto_claw": return autoClawCount
        case "golden_claw": return goldenClawCount
        case "crab_trap": return crabTrapCount
        default: return 0
        }
    }
    
    private func buyUpgrade(item: UpgradeItem, cost: Int) {
        guard pearls >= cost else { return }
        pearls -= cost
        switch item.id {
        case "auto_claw": autoClawCount += 1
        case "golden_claw": goldenClawCount += 1
        case "crab_trap": crabTrapCount += 1
        default: break
        }
    }
}

// MARK: - Helper Components
struct FloatingParticle: Identifiable {
    let id = UUID()
    let value: Int
    var position: CGPoint
    var opacity: Double = 1.0
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.system(.subheadline, design: .rounded).bold())
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct NavButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? .orange : .gray)
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : .gray)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Info / About Sheet
struct InfoSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.10, blue: 0.20)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("🦀")
                            .font(.system(size: 70))
                        Text("Cua App iOS")
                            .font(.title.bold())
                            .foregroundColor(.white)
                        Text("Phiên bản 1.0.0 • Build via GitHub Actions")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 24)
                    
                    VStack(alignment: .leading, spacing: 14) {
                        FeatureRow(icon: "hammer.fill", title: "Unsigned IPA", desc: "Build tự động qua CI/CD không cần tài khoản Apple Developer trả phí.")
                        FeatureRow(icon: "bolt.badge.checkmark.fill", title: "Cài đặt dễ dàng", desc: "Hỗ trợ cài qua TrollStore, Sideloadly, AltStore, Scarlet, Feather.")
                        FeatureRow(icon: "sparkles", title: "SwiftUI Native", desc: "Hiệu năng mượt mà 120Hz ProMotion trên iOS 16+.")
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Đóng")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let desc: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.orange)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                Text(desc)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    ContentView()
}
