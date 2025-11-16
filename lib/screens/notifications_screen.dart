import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      type: NotificationType.overdue,
      title: 'Quá hạn: Gửi email cho khách hàng',
      description: 'Công việc này đã trễ 1 ngày. Vui lòng hoàn thành ngay.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      icon: Icons.error_outline,
      iconColor: AppColors.error,
    ),
    NotificationItem(
      id: '2',
      type: NotificationType.upcoming,
      title: 'Sắp tới hạn: Hoàn thành báo cáo tháng',
      description: 'Công việc sẽ hết hạn vào 5:00 chiều nay.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      icon: Icons.access_time,
      iconColor: const Color(0xFFD9957A), // Orange
    ),
    NotificationItem(
      id: '3',
      type: NotificationType.reminder,
      title: 'Nhắc nhở: Họp team dự án X',
      description: 'Cuộc họp sẽ bắt đầu lúc 10:00 sáng nay.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      icon: Icons.notifications_outlined,
      iconColor: AppColors.primaryLight,
    ),
    NotificationItem(
      id: '4',
      type: NotificationType.newTask,
      title: 'Bạn có công việc mới',
      description: 'Chuẩn bị slide thuyết trình cho cuộc họp tuần tới.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      icon: Icons.add_task,
      iconColor: AppColors.success,
    ),
  ];

  void _handleReadAll() {
    setState(() {
      // Mark all as read - in a real app, you would update the isRead property
      // For now, we'll just show a message
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã đánh dấu tất cả là đã đọc'),
      ),
    );
  }

  void _handleNotificationTap(NotificationItem notification) {
    // TODO: Navigate to task detail or handle notification action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã mở: ${notification.title}'),
      ),
    );
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
        child: _notifications.isEmpty
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
            : ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  return _buildNotificationItem(_notifications[index]);
                },
              ),
      ),
    );
  }
}

