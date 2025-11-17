import 'package:flutter/foundation.dart';
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

      // Sign up without email confirmation
      // Set emailRedirectTo to null để không yêu cầu xác nhận email
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: userData,
        emailRedirectTo: null, // Bỏ xác nhận email
      );

      if (response.user == null) {
        throw Exception('Đăng ký thất bại. Vui lòng thử lại.');
      }

      // Nếu user đã được tạo nhưng chưa có session (do email confirmation)
      // Thì tự động đăng nhập luôn
      if (response.session == null && response.user != null) {
        // User đã được tạo nhưng cần confirm email
        // Với emailRedirectTo: null, user sẽ được tạo và có thể đăng nhập ngay
        debugPrint('✅ User đã được tạo: ${response.user!.email}');
      }

      return response;
    } on AuthException catch (e) {
      // Handle Supabase Auth specific errors
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Lỗi đăng ký: ${e.toString()}');
    }
  }

  /// Đăng ký với email và gửi OTP qua email
  ///
  /// REST API: POST /auth/v1/otp
  ///
  /// [email] - Email người dùng
  /// [fullName] - Họ và tên
  ///
  /// Returns: true nếu thành công
  /// Throws: Exception nếu có lỗi
  Future<bool> signUpWithEmailOTP({
    required String email,
    required String fullName,
  }) async {
    try {
      // Validate email
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('Email không hợp lệ');
      }
      if (fullName.isEmpty) {
        throw Exception('Vui lòng nhập họ và tên');
      }

      // Send OTP to email for signup
      // QUAN TRỌNG: Để gửi mã OTP thay vì Magic Link, cần cấu hình Email Template trong Supabase Dashboard
      // Vào Authentication > Email Templates > Magic Link
      // Thêm {{ .Token }} vào template để hiển thị mã OTP 8 số
      //
      // Lưu ý: Với OTP signup, user sẽ được tạo khi verify OTP thành công
      // Trigger handle_new_user() sẽ tự động tạo profile trong public.profiles
      // với full_name từ user metadata
      await _client.auth.signInWithOtp(
        email: email.trim(),
        data: {
          'full_name': fullName.trim(),
        },
        emailRedirectTo: null, // Không redirect, chỉ gửi OTP
      );

      return true;
    } on AuthException catch (e) {
      // Log chi tiết lỗi để debug
      debugPrint('❌ AuthException khi gửi OTP: ${e.message}');
      debugPrint('   Status code: ${e.statusCode}');
      throw _handleAuthError(e);
    } catch (e) {
      debugPrint('❌ Lỗi khi gửi OTP: $e');
      throw Exception('Lỗi gửi OTP: ${e.toString()}');
    }
  }

  /// Xác nhận OTP và đăng ký/đăng nhập
  ///
  /// REST API: POST /auth/v1/verify
  ///
  /// [email] - Email người dùng
  /// [token] - Mã OTP 4 số
  ///
  /// Returns: AuthResponse nếu thành công
  /// Throws: Exception nếu có lỗi
  Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
  }) async {
    try {
      // Validate email
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('Email không hợp lệ');
      }

      // Verify OTP via email
      // Khi verify OTP thành công, Supabase sẽ:
      // 1. Tạo user trong auth.users (nếu chưa tồn tại)
      // 2. Trigger handle_new_user() tự động tạo profile trong public.profiles
      // 3. Profile sẽ có full_name từ user metadata (raw_user_meta_data->>'full_name')
      String otpToken = token.trim();

      // Verify với mã đầy đủ (8 số)
      final response = await _client.auth.verifyOTP(
        email: email.trim(),
        token: otpToken,
        type: OtpType.email,
      );

      if (response.session == null) {
        throw Exception('Xác nhận OTP thất bại. Vui lòng thử lại.');
      }

      // Đảm bảo profile được tạo sau khi verify OTP
      // Trigger handle_new_user() sẽ tự động chạy khi user được tạo
      // Nhưng nếu user đã tồn tại (login), trigger không chạy
      // Vì vậy cần kiểm tra và tạo profile nếu chưa có
      if (response.user != null) {
        try {
          // Kiểm tra xem profile đã tồn tại chưa
          final profileCheck = await _client
              .from('profiles')
              .select('id')
              .eq('id', response.user!.id)
              .maybeSingle();

          // Nếu profile chưa tồn tại, tạo mới
          if (profileCheck == null) {
            await _client.from('profiles').insert({
              'id': response.user!.id,
              'full_name': response.user!.userMetadata?['full_name'] ?? '',
            });
            debugPrint('✅ Đã tạo profile cho user: ${response.user!.email}');
          }
        } catch (e) {
          // Nếu có lỗi khi tạo profile, log nhưng không throw
          // Vì user đã đăng nhập thành công
          debugPrint('⚠️ Lỗi khi tạo profile (có thể đã tồn tại): $e');
        }
      }

      return response;
    } on AuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Lỗi xác nhận OTP: ${e.toString()}');
    }
  }

  /// Gửi OTP để đăng nhập bằng email
  ///
  /// REST API: POST /auth/v1/otp
  ///
  /// [email] - Email người dùng
  ///
  /// Returns: true nếu thành công
  /// Throws: Exception nếu có lỗi
  Future<bool> sendLoginOTP(String email) async {
    try {
      // Validate email
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('Email không hợp lệ');
      }

      // Send OTP via email
      // QUAN TRỌNG: Để gửi mã OTP thay vì Magic Link, cần cấu hình Email Template trong Supabase Dashboard
      // Vào Authentication > Email Templates > Magic Link
      // Thêm {{ .Token }} vào template để hiển thị mã OTP 6 số
      await _client.auth.signInWithOtp(
        email: email.trim(),
        emailRedirectTo: null, // Không redirect, chỉ gửi OTP
      );

      debugPrint('✅ OTP đã được gửi đến: ${email.trim()}');
      return true;
    } on AuthException catch (e) {
      // Log chi tiết lỗi để debug
      debugPrint('❌ AuthException khi gửi OTP: ${e.message}');
      debugPrint('   Status code: ${e.statusCode}');
      throw _handleAuthError(e);
    } catch (e) {
      debugPrint('❌ Lỗi khi gửi OTP: $e');
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

  /// Đăng nhập bằng email với password hoặc OTP
  /// Tự động phát hiện loại đăng nhập dựa trên có password hay không
  ///
  /// [email] - Email người dùng
  /// [password] - Mật khẩu (nếu null thì gửi OTP)
  ///
  /// Returns: AuthResponse nếu thành công
  /// Throws: Exception nếu có lỗi
  Future<AuthResponse> signInWithIdentifier({
    required String email,
    String? password,
  }) async {
    if (password != null && password.isNotEmpty) {
      // Sign in with email and password
      return await signIn(email: email, password: password);
    } else {
      // Sign in with email - send OTP
      await sendLoginOTP(email);
      // Return a response indicating OTP was sent
      // The actual sign-in will happen after OTP verification
      throw Exception(
          'OTP đã được gửi đến email. Vui lòng nhập mã OTP để đăng nhập.');
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
    final statusCode = e.statusCode;

    // Email sending errors (500)
    if (statusCode == 500 &&
        (message.contains('sending') ||
            message.contains('magic link') ||
            message.contains('email') ||
            message.contains('unexpected_failure'))) {
      return Exception('Không thể gửi email OTP. Vui lòng:\n'
          '1. Kiểm tra cấu hình SMTP trong Supabase Dashboard\n'
          '2. Đảm bảo Email provider đã được bật\n'
          '3. Kiểm tra Email Templates đã được cấu hình\n'
          '4. Thử lại sau vài phút');
    }

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

    // Server errors (500)
    if (statusCode == 500) {
      return Exception('Lỗi server. Vui lòng:\n'
          '1. Kiểm tra Supabase Dashboard > Logs\n'
          '2. Đảm bảo tất cả services đã được cấu hình đúng\n'
          '3. Thử lại sau vài phút');
    }

    // Default: return original message
    return Exception('Lỗi: ${e.message}');
  }
}
