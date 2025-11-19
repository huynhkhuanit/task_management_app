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
    final iconColor = notification.iconColor ?? AppColors.primary;
    final isUpcoming = notification.type == NotificationType.upcoming;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          isUpcoming
              ? AppDimensions.borderRadiusMedium
              : AppDimensions.borderRadiusLarge,
        ),
        border: Border.all(
          color: iconColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Icon(
        notification.icon,
        color: iconColor,
        size: 24,
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    final isUnread = !notification.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleNotificationTap(notification),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusLarge),
              border: Border.all(
                color: isUnread
                    ? (notification.iconColor ?? AppColors.primary)
                        .withOpacity(0.3)
                    : AppColors.greyLight,
                width: isUnread ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unread indicator bar
                if (isUnread)
                  Container(
                    width: 4,
                    // margin: const EdgeInsets.only(
                    //     right: AppDimensions.paddingMedium),
                    decoration: BoxDecoration(
                      color: notification.iconColor ?? AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                else
                  const SizedBox(width: 4 + AppDimensions.paddingMedium),
                // Notification icon
                _buildNotificationIcon(notification),
                const SizedBox(width: AppDimensions.paddingMedium),
                // Notification content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: R.styles.body(
                                size: 16,
                                weight: FontWeight.w700,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(
                                top: 6,
                                left: AppDimensions.paddingSmall,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    notification.iconColor ?? AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      Text(
                        notification.description,
                        style: R.styles
                            .body(
                              size: 14,
                              color: AppColors.greyDark,
                            )
                            .copyWith(height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: AppColors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            notification.getTimeAgo(),
                            style: R.styles.body(
                              size: 12,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FC),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
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
        child: Container(
          color: const Color(0xFFF7F9FC),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingLarge,
                                vertical: AppDimensions.paddingMedium,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.borderRadiusMedium,
                                ),
                              ),
                            ),
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
                              Container(
                                padding: const EdgeInsets.all(
                                  AppDimensions.paddingLarge,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.notifications_none,
                                  size: 48,
                                  color: AppColors.greyLight,
                                ),
                              ),
                              const SizedBox(
                                  height: AppDimensions.paddingLarge),
                              Text(
                                'Không có thông báo',
                                style: R.styles.body(
                                  size: 16,
                                  color: AppColors.grey,
                                  weight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                  height: AppDimensions.paddingSmall),
                              Text(
                                'Các thông báo mới sẽ xuất hiện ở đây',
                                style: R.styles.body(
                                  size: 14,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadNotifications,
                          color: AppColors.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(
                              AppDimensions.paddingLarge,
                            ),
                            itemCount: _notifications.length,
                            itemBuilder: (context, index) {
                              return _buildNotificationItem(
                                  _notifications[index]);
                            },
                          ),
                        ),
        ),
      ),
    );
  }
}
