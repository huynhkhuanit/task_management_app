import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import 'supabase_service.dart';

/// Notification Service - Xử lý notifications
class NotificationService {
  final SupabaseClient _client = SupabaseService.client;
  
  /// Lấy tất cả notifications của user hiện tại
  /// 
  /// [isRead] - Lọc theo trạng thái đã đọc (optional)
  /// [limit] - Giới hạn số lượng (optional)
  /// 
  /// Returns: List of notifications
  Future<List<NotificationItem>> getNotifications({
    bool? isRead,
    int? limit,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');
      
      var query = _client
          .from('notifications')
          .select()
          .eq('user_id', userId);
      
      if (isRead != null) {
        query = query.eq('is_read', isRead) as dynamic;
      }
      
      final response = await query
          .order('created_at', ascending: false)
          .limit(limit ?? 1000);
      return (response as List)
          .map((json) => _notificationFromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy notifications: ${e.toString()}');
    }
  }
  
  /// Lấy số lượng notifications chưa đọc
  Future<int> getUnreadCount() async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');
      
      final response = await _client
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);
      
      return (response as List).length;
    } catch (e) {
      throw Exception('Lỗi đếm notifications: ${e.toString()}');
    }
  }
  
  /// Đánh dấu notification là đã đọc
  Future<void> markAsRead(String notificationId) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');
      
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Lỗi đánh dấu đã đọc: ${e.toString()}');
    }
  }
  
  /// Đánh dấu tất cả notifications là đã đọc
  Future<void> markAllAsRead() async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');
      
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw Exception('Lỗi đánh dấu tất cả đã đọc: ${e.toString()}');
    }
  }
  
  /// Xóa notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');
      
      await _client
          .from('notifications')
          .delete()
          .eq('id', notificationId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Lỗi xóa notification: ${e.toString()}');
    }
  }
  
  /// Xóa tất cả notifications đã đọc
  Future<void> deleteAllRead() async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');
      
      await _client
          .from('notifications')
          .delete()
          .eq('user_id', userId)
          .eq('is_read', true);
    } catch (e) {
      throw Exception('Lỗi xóa notifications đã đọc: ${e.toString()}');
    }
  }
  
  // Helper methods
  NotificationItem _notificationFromJson(Map<String, dynamic> json) {
    final notificationType = _stringToNotificationType(json['type'] as String);
    return NotificationItem(
      id: json['id'] as String,
      type: notificationType,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      timestamp: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      iconColor: _getIconColorForType(notificationType),
      icon: _getIconForType(notificationType),
    );
  }
  
  NotificationType _stringToNotificationType(String type) {
    switch (type) {
      case 'overdue':
        return NotificationType.overdue;
      case 'upcoming':
        return NotificationType.upcoming;
      case 'reminder':
        return NotificationType.reminder;
      case 'newTask':
        return NotificationType.newTask;
      default:
        return NotificationType.reminder;
    }
  }
  
  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.overdue:
        return Icons.error_outline;
      case NotificationType.upcoming:
        return Icons.access_time;
      case NotificationType.reminder:
        return Icons.notifications_outlined;
      case NotificationType.newTask:
        return Icons.add_task;
    }
  }
  
  Color _getIconColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.overdue:
        return const Color(0xFFFF3B30); // Red
      case NotificationType.upcoming:
        return const Color(0xFFD9957A); // Orange
      case NotificationType.reminder:
        return const Color(0xFF4FD1C7); // Teal
      case NotificationType.newTask:
        return const Color(0xFF10B981); // Green
    }
  }
}

