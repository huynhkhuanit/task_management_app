import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

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

    // Đọc từ .env hoặc dart-define (khi build với --dart-define)
    // Ưu tiên: url/anonKey parameter > dart-define > .env file
    final dartDefineUrl =
        const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    final supabaseUrl = url ??
        (dartDefineUrl.isNotEmpty ? dartDefineUrl : dotenv.env['SUPABASE_URL']);

    final dartDefineKey =
        const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    final supabaseAnonKey = anonKey ??
        (dartDefineKey.isNotEmpty
            ? dartDefineKey
            : dotenv.env['SUPABASE_ANON_KEY']);

    // Debug logging để kiểm tra credentials
    if (kDebugMode) {
      debugPrint('🔍 Checking Supabase credentials...');
      debugPrint(
          '  - Parameter URL: ${url != null ? "✅ Provided" : "❌ Not provided"}');
      debugPrint(
          '  - Dart-define URL: ${dartDefineUrl.isNotEmpty ? "✅ $dartDefineUrl" : "❌ Empty"}');
      debugPrint(
          '  - .env URL: ${dotenv.env['SUPABASE_URL'] != null ? "✅ ${dotenv.env['SUPABASE_URL']}" : "❌ Not found"}');
      debugPrint('  - Final URL: ${supabaseUrl ?? "❌ NULL"}');
      debugPrint(
          '  - Parameter Key: ${anonKey != null ? "✅ Provided" : "❌ Not provided"}');
      debugPrint(
          '  - Dart-define Key: ${dartDefineKey.isNotEmpty ? "✅ ${dartDefineKey.substring(0, 20)}..." : "❌ Empty"}');
      debugPrint(
          '  - .env Key: ${dotenv.env['SUPABASE_ANON_KEY'] != null ? "✅ ${dotenv.env['SUPABASE_ANON_KEY']!.substring(0, 20)}..." : "❌ Not found"}');
      debugPrint(
          '  - Final Key: ${supabaseAnonKey != null ? "✅ ${supabaseAnonKey.substring(0, 20)}..." : "❌ NULL"}');
    }

    if (supabaseUrl == null ||
        supabaseUrl.isEmpty ||
        supabaseAnonKey == null ||
        supabaseAnonKey.isEmpty) {
      final errorMsg = 'Supabase credentials chưa được cấu hình.\n'
          'Vui lòng:\n'
          '1. Tạo file .env với SUPABASE_URL và SUPABASE_ANON_KEY\n'
          '2. Hoặc build với --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...\n'
          '3. Hoặc truyền url và anonKey vào initialize()\n\n'
          'Debug info:\n'
          '- Dart-define URL: ${dartDefineUrl.isEmpty ? "Empty" : dartDefineUrl}\n'
          '- .env URL: ${dotenv.env['SUPABASE_URL'] ?? "Not found"}\n'
          '- Dart-define Key: ${dartDefineKey.isEmpty ? "Empty" : "${dartDefineKey.substring(0, 20)}..."}\n'
          '- .env Key: ${dotenv.env['SUPABASE_ANON_KEY'] != null ? "${dotenv.env['SUPABASE_ANON_KEY']!.substring(0, 20)}..." : "Not found"}';
      throw Exception(errorMsg);
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    _client = Supabase.instance.client;
    _isInitialized = true;
  }

  /// Get Supabase client instance
  ///
  /// Nếu chưa được khởi tạo, sẽ throw exception với hướng dẫn rõ ràng
  static SupabaseClient get client {
    // Nếu đã khởi tạo, trả về client
    if (_client != null) {
      return _client!;
    }

    // Nếu chưa khởi tạo, kiểm tra xem Supabase.instance có được khởi tạo chưa
    try {
      // Thử truy cập Supabase.instance.client
      // Nếu đã được khởi tạo ở đâu đó, sẽ trả về client
      final instance = Supabase.instance;
      _client = instance.client;
      _isInitialized = true;
      return _client!;
    } catch (e) {
      // Supabase chưa được khởi tạo
      // Kiểm tra xem có credentials trong .env không
      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (supabaseUrl == null || supabaseAnonKey == null) {
        throw Exception(
            'Supabase chưa được khởi tạo và không tìm thấy credentials.\n'
            'Vui lòng:\n'
            '1. Tạo file .env ở thư mục gốc của project\n'
            '2. Thêm SUPABASE_URL và SUPABASE_ANON_KEY vào file .env\n'
            '3. Đảm bảo SupabaseService.initialize() được gọi trong main()');
      } else {
        throw Exception('Supabase chưa được khởi tạo.\n'
            'Đã tìm thấy credentials trong .env nhưng SupabaseService.initialize() chưa được gọi.\n'
            'Vui lòng đảm bảo SupabaseService.initialize() được gọi trong main() trước khi runApp().');
      }
    }
  }

  /// Get current authenticated user
  /// Returns null nếu chưa khởi tạo hoặc chưa đăng nhập
  static User? get currentUser {
    try {
      return client.auth.currentUser;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  static bool get isLoggedIn {
    try {
      return currentUser != null;
    } catch (e) {
      return false;
    }
  }

  /// Get current user ID
  /// Returns null nếu chưa khởi tạo hoặc chưa đăng nhập
  static String? get currentUserId {
    try {
      return currentUser?.id;
    } catch (e) {
      return null;
    }
  }

  /// Sign out current user
  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}
