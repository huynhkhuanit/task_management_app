import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/task_service.dart';
import '../utils/navigation_helper.dart';
import 'task_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notificationService = NotificationService();
  final _taskService = TaskService();
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Kiểm tra và tạo notifications mới trước khi load
      // Điều này đảm bảo các notifications cho overdue/upcoming tasks được tạo tự động
      try {
        await _notificationService.checkAndCreateOverdueNotifications();
        await _notificationService.checkAndCreateUpcomingNotifications();
      } catch (e) {
        // Log nhưng không fail - đây là background check
        debugPrint('Lỗi kiểm tra notifications: ${e.toString()}');
      }

      // Load notifications từ database
      final notifications = await _notificationService.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải thông báo: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleReadAll() async {
    try {
      await _notificationService.markAllAsRead();
      await _loadNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã đánh dấu tất cả là đã đọc'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đánh dấu đã đọc: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleNotificationTap(NotificationItem notification) async {
    // Mark notification as read
    if (!notification.isRead) {
      try {
        await _notificationService.markAsRead(notification.id);
        await _loadNotifications();
      } catch (e) {
        // Log error but continue with navigation
        debugPrint('Lỗi đánh dấu đã đọc: ${e.toString()}');
      }
    }

    // Navigate to task detail screen if task_id exists
    if (notification.taskId != null) {
      try {
        final task = await _taskService.getTaskById(notification.taskId!);
        if (mounted) {
          NavigationHelper.pushSlideTransition(
            context,
            TaskDetailScreen(task: task),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi tải chi tiết công việc: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } else {
      // No task_id, just show a message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thông báo này không liên quan đến công việc cụ thể'),
          ),
        );
      }
    }
  }

  Widget _buildNotificationIcon(NotificationItem notification) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: notification.iconColor?.withOpacity(0.2) ??
            AppColors.primaryLight.withOpacity(0.2),
        borderRadius: BorderRadius.circular(
          notification.type == NotificationType.upcoming ? 8 : 20,
        ),
      ),
      child: Icon(
        notification.icon,
        color: notification.iconColor ?? AppColors.primary,
        size: 20,
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return InkWell(
      onTap: () => _handleNotificationTap(notification),
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: notification.getBackgroundColor(),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blue dot indicator for unread
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(
                  top: 6,
                  right: AppDimensions.paddingSmall,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(width: 8 + AppDimensions.paddingSmall),
            // Notification icon
            _buildNotificationIcon(notification),
            const SizedBox(width: AppDimensions.paddingMedium),
            // Notification content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: R.styles.body(
                      size: 16,
                      weight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.description,
                    style: R.styles.body(
                      size: 14,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.getTimeAgo(),
                    style: R.styles.body(
                      size: 12,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Thông báo',
          style: R.styles.heading2(
            color: AppColors.black,
            weight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _handleReadAll,
            child: Text(
              'Đọc tất cả',
              style: R.styles.body(
                size: 14,
                weight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: AppDimensions.paddingLarge),
                        Text(
                          'Lỗi tải thông báo',
                          style: R.styles.body(
                            size: 16,
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingMedium),
                        ElevatedButton(
                          onPressed: _loadNotifications,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  )
                : _notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 64,
                              color: AppColors.greyLight,
                            ),
                            const SizedBox(height: AppDimensions.paddingLarge),
                            Text(
                              'Không có thông báo',
                              style: R.styles.body(
                                size: 16,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadNotifications,
                        child: ListView.builder(
                          padding:
                              const EdgeInsets.all(AppDimensions.paddingLarge),
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            return _buildNotificationItem(
                                _notifications[index]);
                          },
                        ),
                      ),
      ),
    );
  }
}
