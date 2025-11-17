import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase Service - Singleton để quản lý Supabase client
class SupabaseService {
  static SupabaseClient? _client;
  static bool _isInitialized = false;
  
  /// Initialize Supabase với URL và anon key từ .env file
  /// Gọi hàm này trong main() trước khi runApp()
  /// 
  /// Nếu muốn override với custom values, có thể truyền url và anonKey
  static Future<void> initialize({
    String? url,
    String? anonKey,
  }) async {
    if (_isInitialized) {
      return; // Đã khởi tạo rồi, không cần khởi tạo lại
    }
    
    // Đọc từ .env nếu không được truyền vào
    final supabaseUrl = url ?? dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = anonKey ?? dotenv.env['SUPABASE_ANON_KEY'];
    
    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception(
        'Supabase credentials chưa được cấu hình. '
        'Vui lòng kiểm tra file .env hoặc truyền url và anonKey vào initialize().'
      );
    }
    
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    _client = Supabase.instance.client;
    _isInitialized = true;
  }
  
  /// Get Supabase client instance
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase chưa được khởi tạo. Gọi SupabaseService.initialize() trước.');
    }
    return _client!;
  }
  
  /// Get current authenticated user
  static User? get currentUser => client.auth.currentUser;
  
  /// Check if user is logged in
  static bool get isLoggedIn => currentUser != null;
  
  /// Get current user ID
  static String? get currentUserId => currentUser?.id;
  
  /// Sign out current user
  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}

