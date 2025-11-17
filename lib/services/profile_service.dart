import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Profile Service - Xử lý CRUD operations cho user profile
class ProfileService {
  /// Lazy getter để tránh khởi tạo client trước khi Supabase được initialize
  SupabaseClient get _client => SupabaseService.client;

  /// Lấy profile của user hiện tại
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');

      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Lỗi lấy thông tin profile: ${e.toString()}');
    }
  }

  /// Cập nhật profile của user hiện tại
  Future<void> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? language,
    bool? darkMode,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');

      final Map<String, dynamic> updates = {};
      if (fullName != null) updates['full_name'] = fullName;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (language != null) updates['language'] = language;
      if (darkMode != null) updates['dark_mode'] = darkMode;

      if (updates.isEmpty) {
        throw Exception('Không có thông tin nào để cập nhật');
      }

      await _client
          .from('profiles')
          .update(updates)
          .eq('id', userId);
    } catch (e) {
      throw Exception('Lỗi cập nhật profile: ${e.toString()}');
    }
  }

  /// Lấy full name của user hiện tại
  Future<String?> getFullName() async {
    try {
      final profile = await getProfile();
      return profile['full_name'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Lấy phone number của user hiện tại
  Future<String?> getPhoneNumber() async {
    try {
      final profile = await getProfile();
      return profile['phone_number'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Lấy avatar URL của user hiện tại
  Future<String?> getAvatarUrl() async {
    try {
      final profile = await getProfile();
      return profile['avatar_url'] as String?;
    } catch (e) {
      return null;
    }
  }
}

