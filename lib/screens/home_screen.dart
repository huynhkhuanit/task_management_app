import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../models/task_model.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/notification_badge.dart';
import '../utils/navigation_helper.dart';
import '../services/profile_service.dart';
import '../services/supabase_service.dart';
import '../services/task_service.dart';
import '../services/notification_service.dart';
import 'tasks_screen.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';
import 'statistics_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _profileService = ProfileService();
  final _taskService = TaskService();
  final _notificationService = NotificationService();
  final GlobalKey _tasksScreenKey = GlobalKey();
  final GlobalKey _statisticsScreenKey = GlobalKey();
  String? _userName;
  String? _avatarUrl;
  List<Task> _todayTasks = [];
  int _totalTasks = 0;
  int _completedTasks = 0;
  int _pendingTasks = 0;
  int _overdueTasks = 0;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadTasks();
  }

  Future<void> _loadUserInfo() async {
    try {
      final fullName = await _profileService.getFullName();
      final avatarUrl = await _profileService.getAvatarUrl();
      setState(() {
        _userName = fullName;
        _avatarUrl = avatarUrl;
      });
    } catch (e) {
      // Use first name from email if available
      final user = SupabaseService.currentUser;
      if (user?.email != null) {
        final emailName = user!.email!.split('@')[0];
        setState(() {
          _userName = emailName;
        });
      }
    }
  }

  Future<void> _loadTasks() async {
    try {
      // Load today's tasks
      final today = DateTime.now();
      final todayTasksList = await _taskService.getTasksByDate(today);

      // Load all tasks for statistics
      final allTasks = await _taskService.getTasks();
      final overdueTasksList = await _taskService.getOverdueTasks();

      // Check and create notifications for overdue and upcoming tasks
      try {
        await _notificationService.checkAndCreateOverdueNotifications();
        await _notificationService.checkAndCreateUpcomingNotifications();
      } catch (e) {
        // Log but don't fail - notifications are background checks
        debugPrint('Lỗi kiểm tra notifications: ${e.toString()}');
      }

      if (mounted) {
        setState(() {
          _todayTasks = todayTasksList;
          _totalTasks = allTasks.length;
          _completedTasks =
              allTasks.where((t) => t.status == TaskStatus.completed).length;
          _pendingTasks =
              allTasks.where((t) => t.status == TaskStatus.pending).length;
          _overdueTasks = overdueTasksList.length;
        });
      }
    } catch (e) {
      // Silently handle error - UI will show empty state
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Chào buổi sáng';
    } else if (hour < 18) {
      return 'Chào buổi chiều';
    } else {
      return 'Chào buổi tối';
    }
  }

  String _getDisplayName() {
    if (_userName != null && _userName!.isNotEmpty) {
      // Get first name if full name has multiple words
      final parts = _userName!.split(' ');
      return parts.isNotEmpty ? parts.last : _userName!;
    }
    return 'Bạn';
  }

  int _getUnreadNotificationCount() {
    // TODO: Replace with actual notification count from service/state
    // For now, return a sample count (4 unread notifications)
    return 4;
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: Column(
        children: [
          // Top Header
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8D5C4),
                    shape: BoxShape.circle,
                    image: _avatarUrl != null && _avatarUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(_avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _avatarUrl == null || _avatarUrl!.isEmpty
                      ? const Icon(
                          Icons.person,
                          color: AppColors.black,
                          size: 30,
                        )
                      : null,
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                // Greeting
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getGreeting()}, ${_getDisplayName()}!',
                        style: R.styles.heading3(
                          color: AppColors.black,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                // Notification icon with badge
                NotificationBadge(
                  count: _getUnreadNotificationCount(),
                  child: IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.black,
                    ),
                    onPressed: () {
                      NavigationHelper.pushSlideTransition(
                        context,
                        const NotificationsScreen(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingLarge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calendar
                  const CalendarWidget(),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  // Task Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Tổng task',
                          '$_totalTasks',
                          AppColors.black,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingMedium),
                      Expanded(
                        child: _buildSummaryCard(
                          'Hoàn thành',
                          '$_completedTasks',
                          AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Đang chờ',
                          '$_pendingTasks',
                          AppColors.black,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingMedium),
                      Expanded(
                        child: _buildSummaryCard(
                          'Quá hạn',
                          '$_overdueTasks',
                          AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  // Today's Tasks Section - Only show if there are tasks
                  if (_todayTasks.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.paddingXLarge),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Công việc hôm nay',
                          style: R.styles.heading2(
                            color: AppColors.black,
                            weight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentIndex = 1; // Switch to Tasks tab
                            });
                          },
                          child: Text(
                            'Xem tất cả',
                            style: R.styles.body(
                              size: 14,
                              weight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingLarge),
                    // Task List
                    ..._todayTasks.map((task) => _buildTaskCard(task)),
                  ],
                  const SizedBox(height: AppDimensions.paddingXLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onboardingBackground,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Home screen (index 0)
          _buildHomeContent(),
          // Tasks screen (index 1)
          TasksScreen(
            key: _tasksScreenKey,
            showBottomNavigationBar: false,
          ),
          // Statistics screen (index 2)
          StatisticsScreen(
            key: _statisticsScreenKey,
          ),
          // Profile screen (index 3)
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Reload tasks when switching back to home tab
          if (index == 0) {
            _loadTasks();
          }
          // Reload TasksScreen when switching to tasks tab
          if (index == 1) {
            final tasksScreenState = _tasksScreenKey.currentState;
            if (tasksScreenState != null && tasksScreenState.mounted) {
              (tasksScreenState as dynamic).reloadTasks();
            }
          }
          // Refresh statistics when switching to statistics tab
          if (index == 2) {
            final statisticsScreenState = _statisticsScreenKey.currentState;
            if (statisticsScreenState != null &&
                statisticsScreenState.mounted) {
              (statisticsScreenState as dynamic).refreshStatistics();
            }
          }
        },
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              heroTag: 'home_fab_tasks',
              onPressed: () async {
                final result = await NavigationHelper.pushSlideTransition<bool>(
                  context,
                  const AddTaskScreen(),
                );
                // Reload tasks when returning from AddTaskScreen if task was created successfully
                if (result == true) {
                  _loadTasks();
                  // Always reload TasksScreen (will be visible when user switches to tasks tab)
                  final tasksScreenState = _tasksScreenKey.currentState;
                  if (tasksScreenState != null && tasksScreenState.mounted) {
                    (tasksScreenState as dynamic).reloadTasks();
                  }
                }
              },
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusLarge),
              ),
              child: const Icon(Icons.add, color: AppColors.white),
            )
          : _currentIndex == 0
              ? FloatingActionButton(
                  heroTag: 'home_fab_home',
                  onPressed: () async {
                    final result = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (context) => const AddTaskScreen(),
                      ),
                    );
                    // Reload tasks when returning from AddTaskScreen if task was created successfully
                    if (result == true) {
                      _loadTasks();
                      // Always reload TasksScreen (will be visible when user switches to tasks tab)
                      final tasksScreenState = _tasksScreenKey.currentState;
                      if (tasksScreenState != null &&
                          tasksScreenState.mounted) {
                        (tasksScreenState as dynamic).reloadTasks();
                      }
                    }
                  },
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusLarge),
                  ),
                  child: const Icon(Icons.add, color: AppColors.white),
                )
              : null,
    );
  }

  Widget _buildSummaryCard(String label, String value, Color labelColor) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: R.styles.body(
              size: 14,
              color: labelColor,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            value,
            style: R.styles.heading1(
              color: AppColors.black,
              weight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final isCompleted = task.status == TaskStatus.completed;
    // Use dueDate if available, otherwise use time
    final taskDateTime = task.dueDate ?? task.time;
    final hour = taskDateTime.hour;
    final minute = taskDateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final timeString =
        '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';

    return InkWell(
      onTap: () async {
        await NavigationHelper.pushSlideTransition(
          context,
          TaskDetailScreen(task: task),
        );
        // Reload tasks when returning from TaskDetailScreen (task might have been updated/deleted)
        await _loadTasks();
        // Also reload TasksScreen if it exists
        final tasksScreenState = _tasksScreenKey.currentState;
        if (tasksScreenState != null && tasksScreenState.mounted) {
          (tasksScreenState as dynamic).reloadTasks();
        }
      },
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        ),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: () async {
                try {
                  final newStatus =
                      isCompleted ? TaskStatus.pending : TaskStatus.completed;

                  // Update task status in database
                  await _taskService.updateTask(
                    taskId: task.id,
                    status: newStatus,
                  );

                  // Reload tasks to reflect changes
                  await _loadTasks();

                  // Also reload TasksScreen if it exists (will be visible when user switches to tasks tab)
                  final tasksScreenState = _tasksScreenKey.currentState;
                  if (tasksScreenState != null && tasksScreenState.mounted) {
                    (tasksScreenState as dynamic).reloadTasks();
                  }
                } catch (e) {
                  // Show error message if update fails
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi cập nhật task: ${e.toString()}'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color:
                        isCompleted ? AppColors.primary : AppColors.greyLight,
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            // Task info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: R.styles
                        .body(
                          size: 16,
                          weight: FontWeight.w700,
                          color: AppColors.black,
                        )
                        .copyWith(
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dự án: ${task.project}',
                    style: R.styles.body(
                      size: 14,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // Time
            Text(
              timeString,
              style: R.styles.body(
                size: 14,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
