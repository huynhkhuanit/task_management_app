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

  /// Đăng ký tài khoản mới
  ///
  /// REST API: POST /auth/v1/signup
  ///
  /// [email] - Email người dùng
  /// [password] - Mật khẩu (tối thiểu 6 ký tự)
  /// [fullName] - Họ và tên
  ///
  /// Returns: AuthResponse chứa User và Session nếu thành công
  /// Throws: AuthException với message chi tiết nếu có lỗi
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
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
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName.trim(),
        },
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
