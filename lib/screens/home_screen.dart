import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../models/task_model.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'tasks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Sample data
  final List<Task> _todayTasks = [
    Task(
      id: '1',
      title: 'Thiết kế màn hình Dashboard',
      project: 'App Quản lý công việc',
      time: DateTime(2023, 12, 5, 10, 0),
      status: TaskStatus.pending,
    ),
    Task(
      id: '2',
      title: 'Họp team định kỳ',
      project: 'Chung',
      time: DateTime(2023, 12, 5, 9, 0),
      status: TaskStatus.completed,
    ),
    Task(
      id: '3',
      title: 'Fix bug giao diện mobile',
      project: 'Website Bán hàng',
      time: DateTime(2023, 12, 5, 11, 0),
      status: TaskStatus.pending,
    ),
  ];

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
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.black,
                    size: 30,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                // Greeting
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getGreeting()}, An!',
                        style: R.styles.heading2(
                          color: AppColors.black,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                // Notification icon
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.black,
                  ),
                  onPressed: () {
                    // TODO: Handle notification
                  },
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
                          '25',
                          AppColors.black,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingMedium),
                      Expanded(
                        child: _buildSummaryCard(
                          'Hoàn thành',
                          '15',
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
                          '5',
                          AppColors.black,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingMedium),
                      Expanded(
                        child: _buildSummaryCard(
                          'Quá hạn',
                          '5',
                          AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingXLarge),
                  // Today's Tasks Section
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
          const TasksScreen(showBottomNavigationBar: false),
          // Statistics screen (index 2) - TODO: Create later
          Center(
            child: Text(
              'Thống kê',
              style: R.styles.heading2(
                color: AppColors.black,
                weight: FontWeight.w700,
              ),
            ),
          ),
          // Profile screen (index 3) - TODO: Create later
          Center(
            child: Text(
              'Hồ sơ',
              style: R.styles.heading2(
                color: AppColors.black,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                // TODO: Add new task
              },
              backgroundColor: AppColors.primary,
              elevation: 0,
              child: const Icon(Icons.add, color: AppColors.white),
            )
          : _currentIndex == 0
              ? FloatingActionButton(
                  onPressed: () {
                    // TODO: Add new task
                  },
                  backgroundColor: AppColors.primary,
                  elevation: 0,
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
    final hour = task.time.hour;
    final minute = task.time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final timeString =
        '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';

    return Container(
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
            onTap: () {
              setState(() {
                final index = _todayTasks.indexWhere((t) => t.id == task.id);
                if (index != -1) {
                  _todayTasks[index] = Task(
                    id: task.id,
                    title: task.title,
                    project: task.project,
                    time: task.time,
                    status:
                        isCompleted ? TaskStatus.pending : TaskStatus.completed,
                  );
                }
              });
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isCompleted ? AppColors.primary : AppColors.greyLight,
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
                        weight: FontWeight.w500,
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
    );
  }
}
