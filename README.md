# 🦀 Ứng dụng iOS "Cua" (Unsigned IPA via GitHub Actions)

Ứng dụng iOS thuần (SwiftUI) với chủ đề **Cua**, được cấu hình sẵn **GitHub Actions CI/CD** để tự động build file `.ipa` (unsigned - không cần chứng chỉ hay tài khoản Apple Developer trả phí) trực tiếp trên đám mây của GitHub.

---

## 📁 Cấu trúc thư mục

```
├── .github/
│   └── workflows/
│       └── build-ipa.yml      # Workflow tự động build file .ipa
├── Cua/
│   ├── App/
│   │   └── CuaApp.swift       # Điểm khởi chạy app SwiftUI
│   ├── Views/
│   │   └── ContentView.swift  # Giao diện & trò chơi bắt cua sinh động
│   └── Resources/
│       ├── Assets.xcassets/   # Màu sắc & Icon
│       └── Info.plist         # Cấu hình Info.plist
├── project.yml                # Cấu hình XcodeGen (tạo Xcode project tự động trên CI)
├── .gitignore
└── README.md
```

---

## 🚀 Hướng dẫn từng bước từ A đến Z

### Bước 1: Đẩy mã nguồn lên GitHub

Mở PowerShell / Command Prompt tại thư mục dự án và chạy các lệnh sau:

```bash
# 1. Khởi tạo Git (nếu chưa có)
git init

# 2. Thêm tất cả file vào git
git add .

# 3. Commit
git commit -m "Initial commit - iOS App Cua"

# 4. Đổi tên nhánh sang main
git branch -M main

# 5. Liên kết với Repository trên GitHub của bạn (thay thế URL bằng repo của bạn)
git remote add origin https://github.com/USERNAME/REPO_NAME.git

# 6. Đẩy code lên GitHub
git push -u origin main
```

---

### Bước 2: Build file `.ipa` trên GitHub Actions

1. Vào repository GitHub của bạn trên trình duyệt.
2. Nhấp vào tab **Actions** ở phía trên.
3. Ở menu bên trái, chọn workflow **🦀 Build Unsigned iOS IPA (Cua)**.
4. Bấm vào nút **Run workflow** -> chọn nhánh `main` -> bấm nút xanh **Run workflow**.
5. Đợi khoảng 1-2 phút để GitHub macOS Runner cài đặt và build hoàn tất.

---

### Bước 3: Tải file `.ipa` về điện thoại hoặc máy tính

1. Khi tiến trình build hoàn thành (hiện dấu tích xanh ✅), bấm vào lần chạy đó.
2. Kéo xuống mục **Artifacts** ở dưới cùng trang tóm tắt.
3. Nhấp vào **Cua-Unsigned-IPA** để tải file `.zip` chứa `Cua.ipa` về máy.
4. Giải nén file `.zip` bạn sẽ nhận được file **`Cua.ipa`**.

---

### Bước 4: Cách cài đặt file IPA Unsigned lên iPhone / iPad

Do file IPA được build ở chế độ **Unsigned** (không yêu cầu chứng chỉ Apple), bạn có thể cài đặt dễ dàng bằng các công cụ sau:

| Phương pháp | Yêu cầu | Cách cài |
| :--- | :--- | :--- |
| **TrollStore** *(Khuyên dùng)* | iOS 14.0 - 16.6.1 / 17.0 | Mở file `Cua.ipa` bằng TrollStore -> Cài đặt vĩnh viễn không bao giờ bị thu hồi chứng chỉ. |
| **Sideloadly** | PC / Mac (Cáp kết nối) | Kéo thả file `Cua.ipa` vào Sideloadly -> Nhập Apple ID miễn phí -> Bấm **Start**. |
| **AltStore** | PC / Mac qua Wi-Fi/Cáp | Mở AltStore trên iPhone -> Chọn dấu `+` -> Chọn `Cua.ipa`. |
| **Scarlet / Feather / Esign** | Trực tiếp trên iPhone | Dùng kèm chứng chỉ DNS/Enterprise hoặc chứng chỉ cá nhân p12. |

---

## ✨ Tính năng nổi bật của App Cua

- 🦀 **Giao diện SwiftUI Native:** Hiệu ứng Glassmorphism đại dương mượt mà, hỗ trợ ProMotion 120Hz.
- 🎮 **Mini Game Bắt Cua:** Tương tác chạm, hiệu ứng rung haptic vật lý và nảy số sinh động.
- 🛒 **Nâng cấp ngư cụ:** Mua Càng Tự Động, Càng Mạ Vàng, Lờ Bắt Cua để gia tăng sản lượng thu hoạch.
- 📖 **Bộ sưu tập loài Cua:** Mở khóa từ Cua Đồng, Cua Biển, Cua Huỳnh Đế đến Cua Vũ Trụ.
- ⚙️ **XcodeGen CI:** Hoàn toàn không phụ thuộc vào máy Mac cục bộ, tự động tạo cấu trúc Xcode hoàn chỉnh trên GitHub Actions.
