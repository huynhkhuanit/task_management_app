# 📱 Task Management App

Ứng dụng quản lý công việc được xây dựng bằng Flutter, giúp người dùng dễ dàng tạo, theo dõi và quản lý các công việc hàng ngày một cách hiệu quả.

## 📋 Giới thiệu

Task Management App là một ứng dụng di động được phát triển bằng Flutter, cung cấp các tính năng quản lý công việc toàn diện. Ứng dụng được thiết kế với giao diện hiện đại, thân thiện với người dùng và hỗ trợ đầy đủ các chức năng cần thiết để quản lý công việc hiệu quả.

## ✨ Tính năng chính

### 🔐 Xác thực người dùng

- **Onboarding**: Hướng dẫn người dùng mới với 3 màn hình giới thiệu
- **Đăng nhập**: Xác thực người dùng với email và mật khẩu
- **Đăng ký**: Tạo tài khoản mới với đầy đủ thông tin
- **Quên mật khẩu**: Khôi phục mật khẩu qua email

### 📊 Dashboard

- **Lịch tháng**: Hiển thị lịch với khả năng chọn ngày, tự động highlight ngày hiện tại
- **Thống kê công việc**:
  - Tổng số công việc
  - Số công việc đã hoàn thành
  - Số công việc đang chờ
  - Số công việc quá hạn
- **Danh sách công việc hôm nay**: Hiển thị các công việc trong ngày với thông tin chi tiết

### ✅ Quản lý công việc

- Tạo công việc mới
- Đánh dấu hoàn thành/Chưa hoàn thành
- Xem thông tin chi tiết công việc (tiêu đề, dự án, thời gian)
- Phân loại công việc theo trạng thái

### 🎨 Giao diện người dùng

- Thiết kế Material Design hiện đại
- Màu sắc nhất quán (#4A90E2)
- Font chữ SF Pro chuyên nghiệp
- Responsive và tối ưu cho nhiều kích thước màn hình
- Bottom Navigation Bar với hiệu ứng chuyển đổi mượt mà

## 🛠️ Công nghệ sử dụng

### Framework & Language

- **Flutter**: Framework phát triển ứng dụng đa nền tảng
- **Dart**: Ngôn ngữ lập trình chính

### Dependencies chính

- `intl: ^0.19.0`: Format ngày tháng và địa phương hóa

### Design System

- **Fonts**: SF Pro (Display, Text, Rounded)
- **Colors**:
  - Primary: `#4A90E2`
  - Background: `#F7F9FC`
  - Custom color palette theo Material Design

## 📁 Cấu trúc dự án

```
lib/
├── constants/
│   └── app_constants.dart          # Colors, Dimensions
├── models/
│   ├── onboarding_model.dart        # Model cho onboarding
│   └── task_model.dart             # Model cho công việc
├── res/
│   ├── drawables/                  # Drawable resources
│   └── fonts/                      # Font resources & styles
├── screens/
│   ├── onboarding_screen.dart      # Màn hình onboarding
│   ├── login_screen.dart           # Màn hình đăng nhập
│   ├── signup_screen.dart          # Màn hình đăng ký
│   ├── forgot_password_screen.dart  # Màn hình quên mật khẩu
│   └── home_screen.dart            # Màn hình dashboard chính
├── widgets/
│   ├── bottom_navigation_bar.dart  # Bottom navigation bar
│   ├── calendar_widget.dart        # Widget lịch
│   ├── custom_buttons.dart         # Custom buttons
│   ├── custom_input_field.dart     # Custom input fields
│   ├── onboarding_page.dart        # Onboarding page widget
│   └── onboarding_page_indicator.dart # Page indicator
└── main.dart                       # Entry point
```

## 🚀 Hướng dẫn cài đặt

### Yêu cầu hệ thống

- Flutter SDK (>=3.3.4)
- Dart SDK
- Android Studio / VS Code với Flutter extension
- Android SDK (cho Android) hoặc Xcode (cho iOS)

### Các bước cài đặt

1. **Clone repository**

```bash
git clone https://github.com/huynhkhuanit/task_management_app.git
cd task_management_app
```

2. **Cài đặt dependencies**

```bash
flutter pub get
```

3. **Chạy ứng dụng**

```bash
flutter run
```

### Build ứng dụng

**Android:**

```bash
flutter build apk --release
```

**iOS:**

```bash
flutter build ios --release
```

## 📱 Screenshots

### Màn hình Onboarding

- 3 màn hình giới thiệu với hình ảnh và mô tả tính năng

### Màn hình Đăng nhập

- Form đăng nhập với email và mật khẩu
- Đăng nhập với Google
- Link đăng ký và quên mật khẩu

### Màn hình Đăng ký

- Form đăng ký với đầy đủ thông tin
- Checkbox đồng ý điều khoản
- Validation form

### Màn hình Dashboard

- Header với avatar và greeting
- Calendar widget
- Task summary cards
- Danh sách công việc hôm nay
- Floating Action Button

## 🎯 Tính năng nổi bật

1. **Calendar Integration**: Lịch tự động hiển thị tháng hiện tại và highlight ngày hôm nay
2. **Task Management**: Quản lý công việc với các trạng thái khác nhau
3. **Statistics**: Thống kê trực quan về công việc
4. **Modern UI/UX**: Giao diện hiện đại, dễ sử dụng
5. **Responsive Design**: Tối ưu cho nhiều kích thước màn hình

## 📚 Tài liệu tham khảo

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design Guidelines](https://material.io/design)

## 👨‍💻 Tác giả

**Huynh Khuan**

- GitHub: [@huynhkhuanit](https://github.com/huynhkhuanit)
- Sinh viên Kỹ thuật Phần mềm - Đại học Hùng Vương, TP.HCM
- Email: [Liên hệ qua GitHub](https://github.com/huynhkhuanit)

## 📄 License

Dự án này được phát triển cho mục đích học tập và nghiên cứu.

## 🙏 Lời cảm ơn

Cảm ơn thầy cô và bạn bè đã hỗ trợ trong quá trình phát triển dự án này.

---

**Lưu ý**: Đây là dự án đồ án môn học, được phát triển với mục đích học tập và nghiên cứu.
