import SwiftUI

struct ContentView: View {
    @AppStorage("cua_high_score") private var highScore: Int = 0
    @AppStorage("cua_unlocked_level") private var unlockedLevel: Int = 1
    
    @State private var selectedLevelForGame: Int? = nil
    @State private var isShowingHowToPlay = false
    @State private var crabBobbing = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Ocean Deep Background
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.12, blue: 0.26),
                        Color(red: 0.02, green: 0.06, blue: 0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Banner & Animated Mascot
                        VStack(spacing: 12) {
                            ZStack {
                                // Background glow
                                Circle()
                                    .fill(Color.orange.opacity(0.2))
                                    .frame(width: 140, height: 140)
                                    .blur(radius: 20)
                                
                                Text("🦀")
                                    .font(.system(size: 84))
                                    .offset(y: crabBobbing ? -8 : 8)
                                    .animation(
                                        .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                                        value: crabBobbing
                                    )
                                    .onAppear {
                                        crabBobbing = true
                                    }
                            }
                            
                            VStack(spacing: 4) {
                                Text("CUA SĂN ỐC")
                                    .font(.system(size: 32, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text("Bắt ốc quay quanh cua • Thử thách 5 Level")
                                    .font(.caption)
                                    .foregroundColor(.cyan)
                            }
                            
                            // High score badge
                            HStack(spacing: 8) {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(.yellow)
                                Text("Kỷ lục: \(highScore) điểm")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.yellow.opacity(0.4), lineWidth: 1))
                        }
                        .padding(.top, 16)
                        
                        // Action: Quick Play Level 1
                        Button {
                            selectedLevelForGame = 0
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "play.fill")
                                    .font(.title2)
                                Text("CHƠI NGAY")
                                    .font(.title3.bold())
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(color: .orange.opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal, 24)
                        
                        // Level Selection Cards
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("Chọn Cấp Độ (5 Levels) 🎯")
                                    .font(.headline.bold())
                                    .foregroundColor(.white)
                                Spacer()
                                Button {
                                    isShowingHowToPlay = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "questionmark.circle.fill")
                                        Text("Luật chơi")
                                    }
                                    .font(.caption.bold())
                                    .foregroundColor(.orange)
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            VStack(spacing: 12) {
                                ForEach(Array(gameLevels.enumerated()), id: \.offset) { index, level in
                                    let isUnlocked = (index + 1) <= unlockedLevel
                                    
                                    Button {
                                        if isUnlocked {
                                            selectedLevelForGame = index
                                        }
                                    } label: {
                                        HStack(spacing: 16) {
                                            // Level number circle
                                            ZStack {
                                                Circle()
                                                    .fill(isUnlocked ? Color.orange.opacity(0.25) : Color.gray.opacity(0.2))
                                                    .frame(width: 46, height: 46)
                                                
                                                if isUnlocked {
                                                    Text("\(level.level)")
                                                        .font(.system(.title3, design: .rounded).bold())
                                                        .foregroundColor(.orange)
                                                } else {
                                                    Image(systemName: "lock.fill")
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 3) {
                                                HStack {
                                                    Text(level.name)
                                                        .font(.headline)
                                                        .foregroundColor(isUnlocked ? .white : .gray)
                                                    
                                                    Spacer()
                                                    
                                                    Text("Mục tiêu: \(level.targetScore)đ")
                                                        .font(.caption2.bold())
                                                        .foregroundColor(isUnlocked ? .yellow : .gray)
                                                }
                                                
                                                Text(level.description)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                                    .multilineTextAlignment(.leading)
                                            }
                                        }
                                        .padding(14)
                                        .background(.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(isUnlocked ? Color.orange.opacity(0.3) : Color.white.opacity(0.05), lineWidth: 1)
                                        )
                                    }
                                    .disabled(!isUnlocked)
                                    .padding(.horizontal, 24)
                                }
                            }
                        }
                        
                        Spacer(minLength: 30)
                    }
                }
            }
            .navigationDestination(isPresented: Binding(
                get: { selectedLevelForGame != nil },
                set: { if !$0 { selectedLevelForGame = nil } }
            )) {
                if let index = selectedLevelForGame {
                    GameView(levelIndex: index)
                }
            }
            .sheet(isPresented: $isShowingHowToPlay) {
                HowToPlaySheet()
            }
        }
    }
}

// MARK: - How to Play Sheet
struct HowToPlaySheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.10, blue: 0.22)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("📖 Cách Chơi Cua Săn Ốc")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        RuleCard(icon: "🦀", title: "Cua Ở Tâm", desc: "Chú Cua đứng cố định ở tâm vòng tròn với đôi càng linh hoạt.")
                        RuleCard(icon: "🐚", title: "Ốc Quay Quỹ Đạo", desc: "Các chú ốc sẽ di chuyển vòng tròn xung quanh Cua.")
                        RuleCard(icon: "👆", title: "Chạm Để Gắp", desc: "Chạm vào màn hình hoặc Cua để phóng càng kẹp chú ốc gần nhất kéo về.")
                        RuleCard(icon: "🔥", title: "Chuỗi Combo", desc: "Gắp trúng liên tục để nhân điểm x2, x3, x4 và mở khóa các Level tiếp theo!")
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Đã Hiểu - Bắt Đầu Chơi! 🚀")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct RuleCard: View {
    let icon: String
    let title: String
    let desc: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(icon)
                .font(.system(size: 32))
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                Text(desc)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .cornerRadius(14)
    }
}
