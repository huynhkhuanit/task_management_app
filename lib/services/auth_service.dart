import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Authentication Service - Xử lý đăng nhập, đăng ký, đổi mật khẩu
class AuthService {
  final SupabaseClient _client = SupabaseService.client;
  
  /// Đăng ký tài khoản mới
  /// 
  /// [email] - Email người dùng
  /// [password] - Mật khẩu (tối thiểu 6 ký tự)
  /// [fullName] - Họ và tên
  /// 
  /// Returns: User object nếu thành công
  /// Throws: Exception nếu có lỗi
  Future<User> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
        },
      );
      
      if (response.user == null) {
        throw Exception('Đăng ký thất bại');
      }
      
      return response.user!;
    } catch (e) {
      throw Exception('Lỗi đăng ký: ${e.toString()}');
    }
  }
  
  /// Đăng nhập với email và password
  /// 
  /// [email] - Email người dùng
  /// [password] - Mật khẩu
  /// 
  /// Returns: Session object nếu thành công
  /// Throws: Exception nếu có lỗi
  Future<Session> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.session == null) {
        throw Exception('Đăng nhập thất bại');
      }
      
      return response.session!;
    } catch (e) {
      throw Exception('Email hoặc mật khẩu không đúng');
    }
  }
  
  /// Đăng nhập với Google
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
    } catch (e) {
      throw Exception('Lỗi đăng nhập với Google: ${e.toString()}');
    }
  }
  
  /// Gửi email reset password
  /// 
  /// [email] - Email người dùng
  /// 
  /// Returns: true nếu thành công
  /// Throws: Exception nếu có lỗi
  Future<bool> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.taskmanagement://reset-password',
      );
      return true;
    } catch (e) {
      throw Exception('Lỗi gửi email reset password: ${e.toString()}');
    }
  }
  
  /// Đổi mật khẩu
  /// 
  /// [newPassword] - Mật khẩu mới
  /// 
  /// Returns: true nếu thành công
  /// Throws: Exception nếu có lỗi
  Future<bool> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return true;
    } catch (e) {
      throw Exception('Lỗi đổi mật khẩu: ${e.toString()}');
    }
  }
  
  /// Đăng xuất
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  /// Lắng nghe thay đổi trạng thái đăng nhập
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}

