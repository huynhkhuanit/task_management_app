import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Authentication Service - Xử lý đăng nhập, đăng ký, đổi mật khẩu
///
/// Sử dụng Supabase Auth REST API:
/// - POST /auth/v1/signup - Đăng ký
/// - POST /auth/v1/token?grant_type=password - Đăng nhập
/// - POST /auth/v1/recover - Reset password
/// - PUT /auth/v1/user - Update password
class AuthService {
  /// Lazy getter để tránh khởi tạo client trước khi Supabase được initialize
  SupabaseClient get _client => SupabaseService.client;

  /// Đăng ký tài khoản mới với email
  ///
  /// REST API: POST /auth/v1/signup
  ///
  /// [email] - Email người dùng
  /// [password] - Mật khẩu (tối thiểu 6 ký tự)
  /// [fullName] - Họ và tên
  /// [phoneNumber] - Số điện thoại (optional)
  ///
  /// Returns: AuthResponse chứa User và Session nếu thành công
  /// Throws: AuthException với message chi tiết nếu có lỗi
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      // Validate input
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('Email không hợp lệ');
      }
      if (password.length < 6) {
        throw Exception('Mật khẩu phải có ít nhất 6 ký tự');
      }
      if (fullName.isEmpty) {
        throw Exception('Vui lòng nhập họ và tên');
      }

      // Call Supabase Auth API
      // Internally calls: POST {SUPABASE_URL}/auth/v1/signup
      final Map<String, dynamic> userData = {
        'full_name': fullName.trim(),
      };
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        userData['phone_number'] = phoneNumber.trim();
      }

      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: userData,
      );

      if (response.user == null) {
        throw Exception('Đăng ký thất bại. Vui lòng thử lại.');
      }

      return response;
    } on AuthException catch (e) {
      // Handle Supabase Auth specific errors
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Lỗi đăng ký: ${e.toString()}');
    }
  }

  /// Đăng ký với số điện thoại và gửi OTP
  ///
  /// REST API: POST /auth/v1/otp
  ///
  /// [phone] - Số điện thoại (format: +84xxxxxxxxx)
  /// [fullName] - Họ và tên
  ///
  /// Returns: true nếu thành công
  /// Throws: Exception nếu có lỗi
  Future<bool> signUpWithPhone({
    required String phone,
    required String fullName,
  }) async {
    try {
      // Validate phone number
      if (phone.isEmpty) {
        throw Exception('Vui lòng nhập số điện thoại');
      }
      if (fullName.isEmpty) {
        throw Exception('Vui lòng nhập họ và tên');
      }

      // Format phone number (ensure it starts with +)
      String formattedPhone = phone.trim();
      if (!formattedPhone.startsWith('+')) {
        // Assume Vietnamese number, add +84
        if (formattedPhone.startsWith('0')) {
          formattedPhone = '+84${formattedPhone.substring(1)}';
        } else {
          formattedPhone = '+84$formattedPhone';
        }
      }

      // Send OTP to phone
      await _client.auth.signInWithOtp(
        phone: formattedPhone,
        data: {
          'full_name': fullName.trim(),
        },
      );

      return true;
    } on AuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Lỗi gửi OTP: ${e.toString()}');
    }
  }

  /// Xác nhận OTP và đăng ký/đăng nhập
  ///
  /// REST API: POST /auth/v1/verify
  ///
  /// [phone] - Số điện thoại
  /// [token] - Mã OTP 6 số
  ///
  /// Returns: AuthResponse nếu thành công
  /// Throws: Exception nếu có lỗi
  Future<AuthResponse> verifyOTP({
    required String phone,
    required String token,
  }) async {
    try {
      // Format phone number
      String formattedPhone = phone.trim();
      if (!formattedPhone.startsWith('+')) {
        if (formattedPhone.startsWith('0')) {
          formattedPhone = '+84${formattedPhone.substring(1)}';
        } else {
          formattedPhone = '+84$formattedPhone';
        }
      }

      // Verify OTP
      final response = await _client.auth.verifyOTP(
        phone: formattedPhone,
        token: token.trim(),
        type: OtpType.sms,
      );

      if (response.session == null) {
        throw Exception('Xác nhận OTP thất bại. Vui lòng thử lại.');
      }

      return response;
    } on AuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Lỗi xác nhận OTP: ${e.toString()}');
    }
  }

  /// Gửi OTP để đăng nhập bằng số điện thoại
  ///
  /// REST API: POST /auth/v1/otp
  ///
  /// [phone] - Số điện thoại
  ///
  /// Returns: true nếu thành công
  /// Throws: Exception nếu có lỗi
  Future<bool> sendLoginOTP(String phone) async {
    try {
      // Format phone number
      String formattedPhone = phone.trim();
      if (!formattedPhone.startsWith('+')) {
        if (formattedPhone.startsWith('0')) {
          formattedPhone = '+84${formattedPhone.substring(1)}';
        } else {
          formattedPhone = '+84$formattedPhone';
        }
      }

      // Send OTP
      await _client.auth.signInWithOtp(phone: formattedPhone);

      return true;
    } on AuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Lỗi gửi OTP: ${e.toString()}');
    }
  }

  /// Đăng nhập với email và password
  ///
  /// REST API: POST /auth/v1/token?grant_type=password
  ///
  /// [email] - Email người dùng
  /// [password] - Mật khẩu
  ///
  /// Returns: AuthResponse chứa Session nếu thành công
  /// Throws: AuthException với message chi tiết nếu có lỗi
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Validate input
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('Email không hợp lệ');
      }
      if (password.isEmpty) {
        throw Exception('Vui lòng nhập mật khẩu');
      }

      // Call Supabase Auth API
      // Internally calls: POST {SUPABASE_URL}/auth/v1/token?grant_type=password
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.session == null) {
        throw Exception('Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.');
      }

      return response;
    } on AuthException catch (e) {
      // Handle Supabase Auth specific errors
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Email hoặc mật khẩu không đúng');
    }
  }

  /// Đăng nhập bằng số điện thoại hoặc email
  /// Tự động phát hiện loại đăng nhập dựa trên input
  ///
  /// [identifier] - Email hoặc số điện thoại
  /// [password] - Mật khẩu (chỉ dùng cho email)
  ///
  /// Returns: AuthResponse nếu thành công
  /// Throws: Exception nếu có lỗi
  Future<AuthResponse> signInWithIdentifier({
    required String identifier,
    String? password,
  }) async {
    // Check if identifier is email or phone
    final isEmail = identifier.contains('@');

    if (isEmail) {
      // Sign in with email and password
      if (password == null || password.isEmpty) {
        throw Exception('Vui lòng nhập mật khẩu');
      }
      return await signIn(email: identifier, password: password);
    } else {
      // Sign in with phone - send OTP
      await sendLoginOTP(identifier);
      // Return a response indicating OTP was sent
      // The actual sign-in will happen after OTP verification
      throw Exception('OTP đã được gửi. Vui lòng nhập mã OTP để đăng nhập.');
    }
  }

  /// Đăng nhập với Google OAuth
  ///
  /// REST API: GET /auth/v1/authorize?provider=google
  ///
  /// Returns: true nếu thành công
  /// Throws: Exception nếu có lỗi
  Future<bool> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.taskmanagement://login-callback',
      );
      return true;
    } on AuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Lỗi đăng nhập với Google: ${e.toString()}');
    }
  }

  /// Gửi email reset password
  ///
  /// REST API: POST /auth/v1/recover
  ///
  /// [email] - Email người dùng
  ///
  /// Returns: true nếu thành công
  /// Throws: Exception nếu có lỗi
  Future<bool> resetPassword(String email) async {
    try {
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('Email không hợp lệ');
      }

      await _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'io.supabase.taskmanagement://reset-password',
      );
      return true;
    } on AuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Lỗi gửi email reset password: ${e.toString()}');
    }
  }

  /// Đổi mật khẩu
  ///
  /// REST API: PUT /auth/v1/user
  ///
  /// [newPassword] - Mật khẩu mới
  ///
  /// Returns: User object nếu thành công
  /// Throws: Exception nếu có lỗi
  Future<User> updatePassword(String newPassword) async {
    try {
      if (newPassword.length < 6) {
        throw Exception('Mật khẩu phải có ít nhất 6 ký tự');
      }

      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        throw Exception('Đổi mật khẩu thất bại');
      }

      return response.user!;
    } on AuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Lỗi đổi mật khẩu: ${e.toString()}');
    }
  }

  /// Đăng xuất
  ///
  /// REST API: POST /auth/v1/logout
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Lỗi đăng xuất: ${e.toString()}');
    }
  }

  /// Lắng nghe thay đổi trạng thái đăng nhập
  ///
  /// Sử dụng để theo dõi khi user đăng nhập/đăng xuất
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Kiểm tra user đã đăng nhập chưa
  bool get isSignedIn => _client.auth.currentUser != null;

  /// Lấy user hiện tại
  User? get currentUser => _client.auth.currentUser;

  /// Lấy session hiện tại
  Session? get currentSession => _client.auth.currentSession;

  /// Xử lý lỗi từ Supabase Auth API
  ///
  /// Chuyển đổi AuthException thành message tiếng Việt dễ hiểu
  Exception _handleAuthError(AuthException e) {
    final message = e.message.toLowerCase();

    // Email errors
    if (message.contains('email') && message.contains('already')) {
      return Exception(
          'Email này đã được sử dụng. Vui lòng đăng nhập hoặc sử dụng email khác.');
    }
    if (message.contains('invalid email')) {
      return Exception('Email không hợp lệ. Vui lòng kiểm tra lại.');
    }

    // Password errors
    if (message.contains('password') && message.contains('weak')) {
      return Exception('Mật khẩu quá yếu. Vui lòng sử dụng mật khẩu mạnh hơn.');
    }
    if (message.contains('invalid password') ||
        message.contains('invalid credentials')) {
      return Exception('Email hoặc mật khẩu không đúng. Vui lòng thử lại.');
    }

    // User not found
    if (message.contains('user not found')) {
      return Exception(
          'Không tìm thấy tài khoản. Vui lòng kiểm tra lại email.');
    }

    // Network errors
    if (message.contains('network') || message.contains('connection')) {
      return Exception('Lỗi kết nối. Vui lòng kiểm tra internet và thử lại.');
    }

    // Rate limiting
    if (message.contains('rate limit') || message.contains('too many')) {
      return Exception('Quá nhiều yêu cầu. Vui lòng đợi một chút và thử lại.');
    }

    // Default: return original message
    return Exception('Lỗi: ${e.message}');
  }
}
