import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../models/task_model.dart';
import '../widgets/bottom_navigation_bar.dart';

class TasksScreen extends StatefulWidget {
  final bool showBottomNavigationBar;

  const TasksScreen({
    Key? key,
    this.showBottomNavigationBar = true,
  }) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int _currentIndex = 1; // Tasks tab is selected
  int _selectedCategoryIndex = 0; // "Tất cả" is selected
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final List<String> _categories = [
    'Tất cả',
    'Hôm nay',
    'Sắp tới',
    'Hoàn thành'
  ];

  // Sample tasks matching the image
  final List<Task> _allTasks = [
    Task(
      id: '1',
      title: 'Thiết kế giao diện màn hình All Tasks',
      project: 'Project X',
      time: DateTime.now(),
      dueDate: DateTime.now().copyWith(hour: 17, minute: 0),
      status: TaskStatus.pending,
      priority: TaskPriority.high,
      tags: ['Ưu tiên cao', 'Project X'],
    ),
    Task(
      id: '2',
      title: 'Hoàn thành báo cáo tuần',
      project: 'Báo cáo',
      time: DateTime.now().add(const Duration(days: 1)),
      dueDate: DateTime.now()
          .add(const Duration(days: 1))
          .copyWith(hour: 11, minute: 0),
      status: TaskStatus.pending,
      priority: TaskPriority.medium,
      tags: ['Ưu tiên trung bình', 'Báo cáo'],
    ),
    Task(
      id: '3',
      title: 'Sửa lỗi đăng nhập trên iOS',
      project: 'Project Y',
      time: DateTime(2023, 12, 25),
      dueDate: DateTime(2023, 12, 25),
      status: TaskStatus.pending,
      priority: TaskPriority.urgent,
      tags: ['Khẩn cấp', 'Project Y'],
    ),
    Task(
      id: '4',
      title: 'Lên kế hoạch cho quý 1/2024',
      project: 'Kế hoạch',
      time: DateTime.now().subtract(const Duration(days: 1)),
      dueDate: DateTime.now()
          .subtract(const Duration(days: 1))
          .copyWith(hour: 9, minute: 0),
      status: TaskStatus.pending,
      priority: TaskPriority.low,
      tags: ['Ưu tiên thấp', 'Kế hoạch'],
    ),
  ];

  List<Task> get _filteredTasks {
    var tasks = _allTasks;

    // Filter by category
    if (_selectedCategoryIndex == 1) {
      // Hôm nay
      final today = DateTime.now();
      tasks = tasks.where((task) {
        if (task.dueDate == null) return false;
        return task.dueDate!.year == today.year &&
            task.dueDate!.month == today.month &&
            task.dueDate!.day == today.day;
      }).toList();
    } else if (_selectedCategoryIndex == 2) {
      // Sắp tới
      final today = DateTime.now();
      tasks = tasks.where((task) {
        if (task.dueDate == null) return false;
        return task.dueDate!.isAfter(today) &&
            !(task.dueDate!.year == today.year &&
                task.dueDate!.month == today.month &&
                task.dueDate!.day == today.day);
      }).toList();
    } else if (_selectedCategoryIndex == 3) {
      // Hoàn thành
      tasks =
          tasks.where((task) => task.status == TaskStatus.completed).toList();
    }

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      tasks = tasks
          .where((task) =>
              task.title.toLowerCase().contains(query) ||
              task.project.toLowerCase().contains(query))
          .toList();
    }

    return tasks;
  }

  String _formatDueDate(DateTime? dueDate) {
    if (dueDate == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (taskDate == today) {
      return 'Hôm nay, ${dueDate.hour.toString().padLeft(2, '0')}:${dueDate.minute.toString().padLeft(2, '0')}';
    } else if (taskDate == tomorrow) {
      return 'Ngày mai, ${dueDate.hour.toString().padLeft(2, '0')}:${dueDate.minute.toString().padLeft(2, '0')}';
    } else if (taskDate == yesterday) {
      return 'Hôm qua, ${dueDate.hour.toString().padLeft(2, '0')}:${dueDate.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dueDate.day.toString().padLeft(2, '0')}/${dueDate.month.toString().padLeft(2, '0')}/${dueDate.year}';
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return const Color(0xFFFF9500); // Orange
      case TaskPriority.medium:
        return const Color(0xFF34C759); // Light green
      case TaskPriority.urgent:
        return const Color(0xFFFF3B30); // Light red
      case TaskPriority.low:
        return const Color(0xFF8E8E93); // Light gray
    }
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'Ưu tiên cao';
      case TaskPriority.medium:
        return 'Ưu tiên trung bình';
      case TaskPriority.urgent:
        return 'Khẩn cấp';
      case TaskPriority.low:
        return 'Ưu tiên thấp';
    }
  }

  // Get light background color for tags
  Color _getTagBackgroundColor(String tag, TaskPriority priority) {
    if (tag.contains('Ưu tiên') || tag == 'Khẩn cấp') {
      switch (priority) {
        case TaskPriority.high:
          return const Color(0xFFFFE5CC); // Light orange
        case TaskPriority.medium:
          return const Color(0xFFD4F4DD); // Light green
        case TaskPriority.urgent:
          return const Color(0xFFFFE5E5); // Light red
        case TaskPriority.low:
          return const Color(0xFFE5E5E5); // Light gray
      }
    }
    // Default colors for project tags
    if (tag == 'Project X' || tag == 'Project Y') {
      return const Color(0xFFE3F2FD); // Light blue
    } else if (tag == 'Báo cáo') {
      return const Color(0xFFF3E5F5); // Light purple
    } else if (tag == 'Kế hoạch') {
      return const Color(0xFFE5E5E5); // Light gray
    }
    return AppColors.primaryLight.withOpacity(0.2);
  }

  // Get dark text color for tags
  Color _getTagTextColor(String tag, TaskPriority priority) {
    if (tag.contains('Ưu tiên') || tag == 'Khẩn cấp') {
      switch (priority) {
        case TaskPriority.high:
          return const Color(0xFFFF9500); // Dark orange
        case TaskPriority.medium:
          return const Color(0xFF34C759); // Dark green
        case TaskPriority.urgent:
          return const Color(0xFFFF3B30); // Dark red
        case TaskPriority.low:
          return const Color(0xFF8E8E93); // Dark gray
      }
    }
    // Default colors for project tags
    if (tag == 'Project X' || tag == 'Project Y') {
      return const Color(0xFF1976D2); // Dark blue
    } else if (tag == 'Báo cáo') {
      return const Color(0xFF7B1FA2); // Dark purple
    } else if (tag == 'Kế hoạch') {
      return const Color(0xFF8E8E93); // Dark gray
    }
    return AppColors.primary;
  }

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {}); // Update UI when focus changes
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: GestureDetector(
        onTap: () {
          // Unfocus search bar when tapping outside
          _searchFocusNode.unfocus();
        },
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLarge,
                  vertical: AppDimensions.paddingMedium,
                ),
                child: Row(
                  children: [
                    // Grid icon
                    IconButton(
                      icon: const Icon(
                        Icons.grid_view,
                        color: AppColors.black,
                        size: AppDimensions.iconMedium,
                      ),
                      onPressed: () {
                        // TODO: Handle menu
                      },
                    ),
                    // Title
                    Expanded(
                      child: Text(
                        'Công việc của tôi',
                        style: R.styles.heading2(
                          color: AppColors.black,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                    // Profile icon
                    IconButton(
                      icon: const Icon(
                        Icons.person,
                        color: AppColors.black,
                        size: AppDimensions.iconMedium,
                      ),
                      onPressed: () {
                        // TODO: Navigate to profile
                      },
                    ),
                  ],
                ),
              ),
              // Search and Filter Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLarge,
                  vertical: AppDimensions.paddingSmall,
                ),
                child: Row(
                  children: [
                    // Search bar
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingSmall,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.greyLight,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusMedium,
                          ),
                          border: _searchFocusNode.hasFocus
                              ? Border.all(
                                  color: AppColors.primary,
                                  width: 1.5,
                                )
                              : null,
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: (_) => setState(() {}),
                          textAlignVertical: TextAlignVertical.center,
                          style: R.styles.body(
                            size: 14,
                            color: AppColors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm công việc...',
                            hintStyle: R.styles.body(
                              size: 14,
                              color: AppColors.grey,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.grey,
                              size: 18,
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 48,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                            isDense: false,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    // Filter button
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.tune,
                          color: AppColors.primary,
                          size: AppDimensions.iconSmall,
                        ),
                        onPressed: () {
                          // TODO: Show filter dialog
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Category Tabs
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLarge,
                  vertical: AppDimensions.paddingSmall,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final tabWidth = constraints.maxWidth / _categories.length;
                    return Column(
                      children: [
                        Row(
                          children: List.generate(
                            _categories.length,
                            (index) => Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCategoryIndex = index;
                                  });
                                },
                                child: Column(
                                  children: [
                                    AnimatedDefaultTextStyle(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      curve: Curves.easeInOut,
                                      style: R.styles.body(
                                        size: 14,
                                        weight: _selectedCategoryIndex == index
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                        color: _selectedCategoryIndex == index
                                            ? AppColors.black
                                            : AppColors.grey,
                                      ),
                                      child: Text(_categories[index]),
                                    ),
                                    const SizedBox(height: 7),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Stack(
                          children: [
                            Container(
                              height: 3,
                              color: Colors.transparent,
                            ),
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              left: _selectedCategoryIndex * tabWidth,
                              bottom: 0,
                              width: tabWidth,
                              height: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Task List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingLarge,
                    vertical: AppDimensions.paddingMedium,
                  ),
                  itemCount: _filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = _filteredTasks[index];
                    return _buildTaskCard(task);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget.showBottomNavigationBar
          ? CustomBottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
                // TODO: Navigate to different screens
              },
            )
          : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new task
        },
        backgroundColor: AppColors.primary,
        elevation: 0,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        border: Border.all(
          color: AppColors.greyLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task title
          Text(
            task.title,
            style: R.styles.body(
              size: 16,
              weight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          // Due date
          Text(
            _formatDueDate(task.dueDate),
            style: R.styles.body(
              size: 14,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          // Tags
          Wrap(
            spacing: AppDimensions.paddingSmall,
            runSpacing: AppDimensions.paddingSmall,
            children: task.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingSmall,
                  vertical: AppDimensions.paddingXSmall,
                ),
                decoration: BoxDecoration(
                  color: _getTagBackgroundColor(tag, task.priority),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusMedium,
                  ),
                ),
                child: Text(
                  tag,
                  style: R.styles.caption(
                    color: _getTagTextColor(tag, task.priority),
                    weight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
