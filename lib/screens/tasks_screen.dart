import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../models/task_model.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../utils/navigation_helper.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';

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

  // Filter states
  Set<TaskPriority> _selectedPriorities = {};
  Set<TaskStatus> _selectedStatuses = {};
  String? _selectedProject;

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

    // Filter by priority
    if (_selectedPriorities.isNotEmpty) {
      tasks = tasks
          .where((task) => _selectedPriorities.contains(task.priority))
          .toList();
    }

    // Filter by status
    if (_selectedStatuses.isNotEmpty) {
      tasks = tasks
          .where((task) => _selectedStatuses.contains(task.status))
          .toList();
    }

    // Filter by project
    if (_selectedProject != null && _selectedProject!.isNotEmpty) {
      tasks = tasks.where((task) => task.project == _selectedProject).toList();
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

  List<String> get _availableProjects {
    return _allTasks.map((task) => task.project).toSet().toList();
  }

  bool get _hasActiveFilters {
    return _selectedPriorities.isNotEmpty ||
        _selectedStatuses.isNotEmpty ||
        (_selectedProject != null && _selectedProject!.isNotEmpty);
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
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _hasActiveFilters
                                ? AppColors.primary
                                : AppColors.primaryLight.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.tune,
                              color: _hasActiveFilters
                                  ? AppColors.white
                                  : AppColors.primary,
                              size: AppDimensions.iconSmall,
                            ),
                            onPressed: () {
                              _showFilterBottomSheet();
                            },
                          ),
                        ),
                        if (_hasActiveFilters)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
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
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedCategoryIndex = index;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                splashColor: AppColors.primary.withOpacity(0.1),
                                highlightColor:
                                    AppColors.primary.withOpacity(0.05),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: AppDimensions.paddingSmall,
                                    right: AppDimensions.paddingSmall,
                                    top: AppDimensions.paddingSmall,
                                    bottom: 3.0,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AnimatedDefaultTextStyle(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        curve: Curves.easeInOut,
                                        style: R.styles.body(
                                          size: 14,
                                          weight:
                                              _selectedCategoryIndex == index
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
      floatingActionButton: widget.showBottomNavigationBar
          ? FloatingActionButton(
              heroTag: 'tasks_screen_fab',
              onPressed: () {
                NavigationHelper.pushSlideTransition(
                  context,
                  const AddTaskScreen(),
                );
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

  void _showFilterBottomSheet() {
    // Temporary state for filter bottom sheet
    Set<TaskPriority> tempPriorities = Set.from(_selectedPriorities);
    Set<TaskStatus> tempStatuses = Set.from(_selectedStatuses);
    String? tempProject = _selectedProject;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.borderRadiusXLarge),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: AppDimensions.paddingMedium),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title Section
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingLarge,
                  AppDimensions.paddingLarge,
                  AppDimensions.paddingLarge,
                  AppDimensions.paddingMedium,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Bộ lọc',
                        style: R.styles.heading2(
                          color: AppColors.black,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (tempPriorities.isNotEmpty ||
                        tempStatuses.isNotEmpty ||
                        (tempProject != null && tempProject!.isNotEmpty))
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempPriorities.clear();
                            tempStatuses.clear();
                            tempProject = null;
                          });
                        },
                        child: Text(
                          'Đặt lại',
                          style: R.styles.body(
                            size: 14,
                            weight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Scrollable Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingLarge,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Priority Filter Section
                      _buildFilterSection(
                        title: 'Mức độ ưu tiên',
                        children: TaskPriority.values.map((priority) {
                          final isSelected = tempPriorities.contains(priority);
                          return _buildFilterChip(
                            label: _getPriorityText(priority),
                            isSelected: isSelected,
                            color: _getPriorityColor(priority),
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  tempPriorities.remove(priority);
                                } else {
                                  tempPriorities.add(priority);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      // Divider
                      Divider(
                        color: AppColors.greyLight,
                        thickness: 1,
                        height: 1,
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      // Status Filter Section
                      _buildFilterSection(
                        title: 'Trạng thái',
                        children: TaskStatus.values.map((status) {
                          final isSelected = tempStatuses.contains(status);
                          String statusText;
                          Color statusColor;
                          switch (status) {
                            case TaskStatus.pending:
                              statusText = 'Đang chờ';
                              statusColor = AppColors.warning;
                              break;
                            case TaskStatus.completed:
                              statusText = 'Hoàn thành';
                              statusColor = AppColors.success;
                              break;
                            case TaskStatus.overdue:
                              statusText = 'Quá hạn';
                              statusColor = AppColors.error;
                              break;
                          }
                          return _buildFilterChip(
                            label: statusText,
                            isSelected: isSelected,
                            color: statusColor,
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  tempStatuses.remove(status);
                                } else {
                                  tempStatuses.add(status);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      // Divider
                      Divider(
                        color: AppColors.greyLight,
                        thickness: 1,
                        height: 1,
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      // Project Filter Section
                      _buildFilterSection(
                        title: 'Dự án',
                        children: _availableProjects.map((project) {
                          final isSelected = tempProject == project;
                          return _buildFilterChip(
                            label: project,
                            isSelected: isSelected,
                            color: AppColors.primary,
                            onTap: () {
                              setModalState(() {
                                tempProject = isSelected ? null : project;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppDimensions.paddingLarge),
                    ],
                  ),
                ),
              ),
              // Action Buttons
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.greyLight,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.paddingSmall,
                          ),
                          minimumSize: const Size(0, 44),
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusMedium,
                            ),
                          ),
                        ),
                        child: Text(
                          'Hủy',
                          style: R.styles.body(
                            size: 16,
                            weight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedPriorities = tempPriorities;
                            _selectedStatuses = tempStatuses;
                            _selectedProject = tempProject;
                          });
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.paddingSmall,
                          ),
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusMedium,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Áp dụng',
                          style: R.styles.body(
                            size: 16,
                            weight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: R.styles.body(
            size: 16,
            weight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        Wrap(
          spacing: AppDimensions.paddingSmall,
          runSpacing: AppDimensions.paddingSmall,
          children: children,
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : AppColors.greyLight.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          border: Border.all(
            color: isSelected ? color : AppColors.greyLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 16,
                color: color,
              )
            else
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.grey,
                    width: 1.5,
                  ),
                ),
              ),
            const SizedBox(width: AppDimensions.paddingSmall),
            Text(
              label,
              style: R.styles.body(
                size: 14,
                weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return InkWell(
      onTap: () {
        NavigationHelper.pushSlideTransition(
          context,
          TaskDetailScreen(task: task),
        );
      },
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      child: Container(
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
      ),
    );
  }
}
