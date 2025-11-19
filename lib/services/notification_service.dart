import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import 'supabase_service.dart';

/// Notification Service - Xử lý notifications
class NotificationService {
  /// Lazy getter để tránh khởi tạo client trước khi Supabase được initialize
  SupabaseClient get _client => SupabaseService.client;
  
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
  
  /// Tạo notification mới
  Future<void> createNotification({
    required String? taskId,
    required NotificationType type,
    required String title,
    String? description,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');
      
      await _client.from('notifications').insert({
        'user_id': userId,
        'task_id': taskId,
        'type': _notificationTypeToString(type),
        'title': title,
        'description': description,
      });
    } catch (e) {
      throw Exception('Lỗi tạo notification: ${e.toString()}');
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
      taskId: json['task_id'] as String?,
    );
  }
  
  String _notificationTypeToString(NotificationType type) {
    switch (type) {
      case NotificationType.overdue:
        return 'overdue';
      case NotificationType.upcoming:
        return 'upcoming';
      case NotificationType.reminder:
        return 'reminder';
      case NotificationType.newTask:
        return 'newTask';
    }
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
  
  /// Kiểm tra và tạo notifications cho tasks quá hạn
  Future<void> checkAndCreateOverdueNotifications() async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');
      
      // Lấy tasks quá hạn chưa có notification trong 24h qua
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      
      final overdueTasks = await _client
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .lt('due_date', now.toIso8601String())
          .neq('status', 'completed');
      
      // Filter out tasks with null due_date (comparison operators already exclude them, but be explicit)
      final validOverdueTasks = (overdueTasks as List).where((task) => task['due_date'] != null).toList();
      
      for (var task in validOverdueTasks) {
        final taskId = task['id'] as String;
        
        // Kiểm tra xem đã có notification cho task này trong 24h qua chưa
        final existingNotifications = await _client
            .from('notifications')
            .select()
            .eq('user_id', userId)
            .eq('task_id', taskId)
            .eq('type', 'overdue')
            .gte('created_at', yesterday.toIso8601String());
        
        if ((existingNotifications as List).isEmpty) {
          await createNotification(
            taskId: taskId,
            type: NotificationType.overdue,
            title: 'Quá hạn: ${task['title']}',
            description: 'Công việc này đã quá hạn. Vui lòng hoàn thành ngay.',
          );
        }
      }
    } catch (e) {
      // Log error but don't throw - this is a background check
      debugPrint('Lỗi kiểm tra overdue notifications: ${e.toString()}');
    }
  }
  
  /// Kiểm tra và tạo notifications cho tasks sắp tới hạn (trong 24h)
  Future<void> checkAndCreateUpcomingNotifications() async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');
      
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      
      final upcomingTasks = await _client
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .gte('due_date', now.toIso8601String())
          .lte('due_date', tomorrow.toIso8601String())
          .neq('status', 'completed');
      
      // Filter out tasks with null due_date
      final validUpcomingTasks = (upcomingTasks as List).where((task) => task['due_date'] != null).toList();
      
      for (var task in validUpcomingTasks) {
        final taskId = task['id'] as String;
        final dueDate = DateTime.parse(task['due_date'] as String);
        
        // Chỉ tạo notification nếu còn ít hơn 24h
        if (dueDate.difference(now).inHours < 24) {
          // Kiểm tra xem đã có notification cho task này trong 12h qua chưa
          final twelveHoursAgo = now.subtract(const Duration(hours: 12));
          final existingNotifications = await _client
              .from('notifications')
              .select()
              .eq('user_id', userId)
              .eq('task_id', taskId)
              .eq('type', 'upcoming')
              .gte('created_at', twelveHoursAgo.toIso8601String());
          
          if ((existingNotifications as List).isEmpty) {
            final hoursUntilDue = dueDate.difference(now).inHours;
            String description;
            if (hoursUntilDue < 1) {
              final minutesUntilDue = dueDate.difference(now).inMinutes;
              description = 'Công việc sẽ hết hạn sau ${minutesUntilDue} phút.';
            } else {
              description = 'Công việc sẽ hết hạn sau ${hoursUntilDue} giờ.';
            }
            
            await createNotification(
              taskId: taskId,
              type: NotificationType.upcoming,
              title: 'Sắp tới hạn: ${task['title']}',
              description: description,
            );
          }
        }
      }
    } catch (e) {
      // Log error but don't throw - this is a background check
      debugPrint('Lỗi kiểm tra upcoming notifications: ${e.toString()}');
    }
  }
}

