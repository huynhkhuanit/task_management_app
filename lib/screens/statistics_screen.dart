import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import '../services/category_service.dart';
import '../services/ai_analysis_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final _taskService = TaskService();
  final _categoryService = CategoryService();
  final _aiAnalysisService = AIAnalysisService();

  int _selectedPeriod = 1; // 0: Tuần, 1: Tháng, 2: Năm
  bool _isLoading = true;

  // Statistics data from database
  double _completionRate = 0.0;
  int _overdueTasks = 0;
  double _performanceScore = 0.0;
  int _totalTasks = 0;
  int _completedTasks = 0;
  List<CategoryData> _categoryData = [];
  List<BarData> _weeklyData = [];
  List<double> _performanceTrend = [];

  // AI Analysis state
  String _aiAnalysis = '';
  bool _isAnalyzing = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _loadStatistics();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Auto refresh when app resumes
      _loadStatistics();
    }
  }

  // Public method to refresh statistics (can be called from parent)
  void refreshStatistics() {
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load all tasks
      final allTasks = await _taskService.getTasks();

      // Filter tasks based on selected period
      final filteredTasks = _filterTasksByPeriod(allTasks);

      // Filter overdue tasks by period
      final overdueTasksList = await _taskService.getOverdueTasks();
      final filteredOverdueTasks = _filterTasksByPeriod(overdueTasksList);

      // Load categories
      final categories = await _categoryService.getCategories();

      // Calculate statistics based on filtered tasks
      _totalTasks = filteredTasks.length;

      // Count completed tasks trong filtered period để đảm bảo tính toán đúng
      // Tối ưu: Sử dụng filteredTasks thay vì allTasks để đảm bảo completion rate chính xác
      final completedTasksInPeriod =
          filteredTasks.where((t) => t.status == TaskStatus.completed).length;

      _overdueTasks = filteredOverdueTasks.length;
      _completedTasks = completedTasksInPeriod;

      // Calculate completion rate - đảm bảo không vượt quá 100%
      _completionRate = _totalTasks > 0
          ? ((completedTasksInPeriod / _totalTasks) * 100).clamp(0.0, 100.0)
          : 0.0;

      // Calculate performance score (0-10 scale)
      // Based on completion rate and overdue tasks penalty
      double baseScore = (_completionRate / 100) * 10;
      double overduePenalty =
          _overdueTasks * 0.5; // Penalty for each overdue task
      _performanceScore = (baseScore - overduePenalty).clamp(0.0, 10.0);

      // Calculate category distribution
      _categoryData = [];
      final categoryColors = [
        AppColors.primary,
        const Color(0xFF10B981),
        const Color(0xFFFF9500),
        const Color(0xFF8B5CF6),
        const Color(0xFFEC4899),
        const Color(0xFF06B6D4),
      ];

      final categoryMap = <String, int>{};
      int noCategoryCount = 0;

      for (var task in filteredTasks) {
        if (task.categoryId != null) {
          categoryMap[task.categoryId!] =
              (categoryMap[task.categoryId!] ?? 0) + 1;
        } else {
          // Count tasks without category
          noCategoryCount++;
        }
      }

      // Tính toán percentage và đảm bảo tổng không vượt quá 100%
      // Cải thiện: Tính tất cả percentage trước, sau đó làm tròn và điều chỉnh để tổng chính xác
      int colorIndex = 0;
      final List<Map<String, dynamic>> tempData = [];

      // Thu thập tất cả dữ liệu với percentage chưa làm tròn
      for (var category in categories) {
        final count = categoryMap[category.id] ?? 0;
        if (count > 0) {
          final percentage =
              _totalTasks > 0 ? (count / _totalTasks) * 100 : 0.0;
          tempData.add({
            'name': category.name,
            'count': count,
            'percentage': percentage,
            'color': categoryColors[colorIndex % categoryColors.length],
          });
          colorIndex++;
        }
      }

      // Thêm "Không có danh mục" nếu có
      if (noCategoryCount > 0) {
        final percentage =
            _totalTasks > 0 ? (noCategoryCount / _totalTasks) * 100 : 0.0;
        tempData.add({
          'name': 'Không có danh mục',
          'count': noCategoryCount,
          'percentage': percentage,
          'color': AppColors.grey,
        });
      }

      // Làm tròn và đảm bảo tổng không vượt quá 100%
      if (tempData.isNotEmpty) {
        int totalRounded = 0;

        // Làm tròn tất cả trừ item cuối cùng
        for (int i = 0; i < tempData.length - 1; i++) {
          final data = tempData[i];
          // Tính phần còn lại có thể dùng
          final remaining = 100 - totalRounded;
          // Làm tròn nhưng không vượt quá phần còn lại
          final rounded =
              ((data['percentage'] as double).round()).clamp(0, remaining);
          totalRounded += rounded;

          _categoryData.add(CategoryData(
            name: data['name'] as String,
            count: data['count'] as int,
            percentage: rounded,
            color: data['color'] as Color,
          ));
        }

        // Item cuối cùng: điều chỉnh để tổng không vượt quá 100%
        final lastData = tempData.last;
        final remaining = (100 - totalRounded).clamp(0, 100);
        final lastPercentage =
            ((lastData['percentage'] as double).round()).clamp(0, remaining);

        _categoryData.add(CategoryData(
          name: lastData['name'] as String,
          count: lastData['count'] as int,
          percentage: lastPercentage,
          color: lastData['color'] as Color,
        ));
      }

      // Calculate completion data based on period - use allTasks to include all completed tasks
      _calculateCompletionData(allTasks);

      // Calculate performance trend based on period - use allTasks to include all tasks
      _calculatePerformanceTrend(allTasks);

      // Gọi AI phân tích dữ liệu
      _loadAIAnalysis();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Gọi AI để phân tích dữ liệu thống kê
  Future<void> _loadAIAnalysis() async {
    if (mounted) {
      setState(() {
        _isAnalyzing = true;
        _aiAnalysis = '';
      });
      _animationController.repeat();
    }

    try {
      // Chuẩn bị dữ liệu thống kê
      final periodNames = ['Tuần', 'Tháng', 'Năm'];
      final categoryDistribution = <String, dynamic>{};
      for (var category in _categoryData) {
        categoryDistribution[category.name] = category.percentage;
      }

      final statistics = {
        'period': periodNames[_selectedPeriod],
        'completionRate': _completionRate,
        'totalTasks': _totalTasks,
        'completedTasks': _completedTasks,
        'overdueTasks': _overdueTasks,
        'performanceScore': _performanceScore,
        'categoryDistribution': categoryDistribution,
      };

      // Gọi AI service
      final analysis = await _aiAnalysisService.analyzeStatistics(statistics);

      if (mounted) {
        setState(() {
          _aiAnalysis = analysis;
          _isAnalyzing = false;
          _animationController.stop();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _aiAnalysis = 'Không thể tải phân tích AI. Vui lòng thử lại sau.';
          _animationController.stop();
        });
      }
    }
  }

  List<Task> _filterTasksByPeriod(List<Task> tasks) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    switch (_selectedPeriod) {
      case 0: // Tuần (Week)
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
        break;
      case 1: // Tháng (Month)
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 2: // Năm (Year)
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, 1);
    }

    return tasks.where((task) {
      final taskDate = task.dueDate ?? task.time;
      return taskDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          taskDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  void _calculateCompletionData(List<Task> tasks) {
    final now = DateTime.now();
    DateTime startDate;
    int daysCount;

    switch (_selectedPeriod) {
      case 0: // Tuần (Week)
        // Calculate week start (Monday)
        final daysFromMonday = (now.weekday - 1) % 7;
        final weekStart =
            DateTime(now.year, now.month, now.day - daysFromMonday);
        startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
        daysCount = 7;
        _weeklyData = [];
        final daysOfWeek = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
        for (int i = 0; i < daysCount; i++) {
          final currentDay =
              DateTime(startDate.year, startDate.month, startDate.day + i);
          final dayStart =
              DateTime(currentDay.year, currentDay.month, currentDay.day);

          // Count completed tasks that were completed on this day
          final completedCount = tasks.where((task) {
            if (task.status != TaskStatus.completed) return false;
            // Use completedAt if available, otherwise fallback to created_at (time)
            final completionDate = task.completedAt ?? task.time;
            // Normalize to date only (remove time component) for comparison
            final completionDateOnly = DateTime(
              completionDate.year,
              completionDate.month,
              completionDate.day,
            );
            // Check if completion date matches this day exactly
            return completionDateOnly.year == dayStart.year &&
                completionDateOnly.month == dayStart.month &&
                completionDateOnly.day == dayStart.day;
          }).length;

          _weeklyData.add(BarData(
            day: daysOfWeek[i],
            value: completedCount,
          ));
        }
        break;
      case 1: // Tháng (Month)
        startDate = DateTime(now.year, now.month, 1);
        daysCount = DateTime(now.year, now.month + 1, 0).day;
        _weeklyData = [];
        // Group by weeks in month
        final weeks = <List<int>>[];
        int currentWeek = 0;
        for (int day = 1; day <= daysCount; day++) {
          final date = DateTime(now.year, now.month, day);
          final weekday = date.weekday;
          if (weekday == 1 || weeks.isEmpty) {
            weeks.add([]);
            currentWeek = weeks.length - 1;
          }
          weeks[currentWeek].add(day);
        }
        for (int i = 0; i < weeks.length && i < 5; i++) {
          final weekDays = weeks[i];
          final weekStart = DateTime(now.year, now.month, weekDays.first);
          final weekEnd = DateTime(now.year, now.month, weekDays.last)
              .add(const Duration(days: 1));

          // Count completed tasks that were completed in this week
          final completedCount = tasks.where((task) {
            if (task.status != TaskStatus.completed) return false;
            // Use completedAt if available, otherwise fallback to created_at (time)
            final completionDate = task.completedAt ?? task.time;
            return completionDate
                    .isAfter(weekStart.subtract(const Duration(days: 1))) &&
                completionDate.isBefore(weekEnd);
          }).length;

          _weeklyData.add(BarData(
            day: 'Tuần ${i + 1}',
            value: completedCount,
          ));
        }
        break;
      case 2: // Năm (Year)
        _weeklyData = [];
        final months = [
          'T1',
          'T2',
          'T3',
          'T4',
          'T5',
          'T6',
          'T7',
          'T8',
          'T9',
          'T10',
          'T11',
          'T12'
        ];
        for (int month = 1; month <= 12; month++) {
          final monthStart = DateTime(now.year, month, 1);
          final monthEnd =
              DateTime(now.year, month + 1, 0).add(const Duration(days: 1));

          // Count completed tasks that were completed in this month
          final completedCount = tasks.where((task) {
            if (task.status != TaskStatus.completed) return false;
            // Use completedAt if available, otherwise fallback to created_at (time)
            final completionDate = task.completedAt ?? task.time;
            return completionDate
                    .isAfter(monthStart.subtract(const Duration(days: 1))) &&
                completionDate.isBefore(monthEnd);
          }).length;

          _weeklyData.add(BarData(
            day: months[month - 1],
            value: completedCount,
          ));
        }
        break;
    }
  }

  void _calculatePerformanceTrend(List<Task> tasks) {
    final now = DateTime.now();
    _performanceTrend = [];

    switch (_selectedPeriod) {
      case 0: // Tuần (Week) - 7 days
        // Calculate week start (Monday)
        final daysFromMonday = (now.weekday - 1) % 7;
        final weekStart =
            DateTime(now.year, now.month, now.day - daysFromMonday);

        for (int i = 0; i < 7; i++) {
          final currentDay =
              DateTime(weekStart.year, weekStart.month, weekStart.day + i);
          final dayStart =
              DateTime(currentDay.year, currentDay.month, currentDay.day);

          // Get tasks that were due or created on this day
          final dayTasks = tasks.where((task) {
            // Use dueDate if available, otherwise use created_at (time)
            final taskDate = task.dueDate ?? task.time;
            final taskDateOnly = DateTime(
              taskDate.year,
              taskDate.month,
              taskDate.day,
            );
            // Check if task date matches this day exactly
            return taskDateOnly.year == dayStart.year &&
                taskDateOnly.month == dayStart.month &&
                taskDateOnly.day == dayStart.day;
          }).toList();

          if (dayTasks.isEmpty) {
            _performanceTrend.add(0.0);
          } else {
            // Count tasks completed on this day (using completedAt)
            final completed = dayTasks.where((t) {
              if (t.status != TaskStatus.completed) return false;
              final completionDate = t.completedAt ?? t.time;
              final completionDateOnly = DateTime(
                completionDate.year,
                completionDate.month,
                completionDate.day,
              );
              // Check if completion date matches this day exactly
              return completionDateOnly.year == dayStart.year &&
                  completionDateOnly.month == dayStart.month &&
                  completionDateOnly.day == dayStart.day;
            }).length;
            final score = (completed / dayTasks.length) * 10;
            _performanceTrend.add(score);
          }
        }
        break;
      case 1: // Tháng (Month) - by weeks
        final monthStart = DateTime(now.year, now.month, 1);
        final weeksInMonth = ((DateTime(now.year, now.month + 1, 0).day +
                    monthStart.weekday -
                    1) /
                7)
            .ceil();
        for (int week = 0; week < weeksInMonth && week < 5; week++) {
          final weekStart =
              monthStart.add(Duration(days: week * 7 - monthStart.weekday + 1));
          final weekEnd = weekStart.add(const Duration(days: 7));

          // Get tasks that were due or created in this week
          final weekTasks = tasks.where((task) {
            final taskDate = task.dueDate ?? task.time;
            return taskDate
                    .isAfter(weekStart.subtract(const Duration(days: 1))) &&
                taskDate.isBefore(weekEnd);
          }).toList();

          if (weekTasks.isEmpty) {
            _performanceTrend.add(0.0);
          } else {
            // Count tasks completed in this week (using completedAt)
            final completed = weekTasks.where((t) {
              if (t.status != TaskStatus.completed) return false;
              final completionDate = t.completedAt ?? t.time;
              return completionDate
                      .isAfter(weekStart.subtract(const Duration(days: 1))) &&
                  completionDate.isBefore(weekEnd);
            }).length;
            final score = (completed / weekTasks.length) * 10;
            _performanceTrend.add(score);
          }
        }
        break;
      case 2: // Năm (Year) - by months
        for (int month = 1; month <= 12; month++) {
          final monthStart = DateTime(now.year, month, 1);
          final monthEnd =
              DateTime(now.year, month + 1, 0).add(const Duration(days: 1));

          // Get tasks that were due or created in this month
          final monthTasks = tasks.where((task) {
            final taskDate = task.dueDate ?? task.time;
            return taskDate
                    .isAfter(monthStart.subtract(const Duration(days: 1))) &&
                taskDate.isBefore(monthEnd);
          }).toList();

          if (monthTasks.isEmpty) {
            _performanceTrend.add(0.0);
          } else {
            // Count tasks completed in this month (using completedAt)
            final completed = monthTasks.where((t) {
              if (t.status != TaskStatus.completed) return false;
              final completionDate = t.completedAt ?? t.time;
              return completionDate
                      .isAfter(monthStart.subtract(const Duration(days: 1))) &&
                  completionDate.isBefore(monthEnd);
            }).length;
            final score = (completed / monthTasks.length) * 10;
            _performanceTrend.add(score);
          }
        }
        break;
    }
  }

  // Get status based on performance score
  String get statusText {
    if (_performanceScore >= 9.0) return 'Xuất sắc';
    if (_performanceScore >= 7.0) return 'Tốt';
    if (_performanceScore >= 5.0) return 'Khá';
    return 'Cần cải thiện';
  }

  Color get statusColor {
    if (_performanceScore >= 9.0) return AppColors.success;
    if (_performanceScore >= 7.0) return AppColors.primary;
    if (_performanceScore >= 5.0) return const Color(0xFFFF9500);
    return AppColors.error;
  }

  IconData get statusIcon {
    if (_performanceScore >= 9.0) return Icons.trending_up;
    if (_performanceScore >= 7.0) return Icons.assessment_outlined;
    if (_performanceScore >= 5.0) return Icons.trending_flat;
    return Icons.trending_down;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onboardingBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              color: Color(0xFFF7F9FC),
              child: Column(
                children: [
                  Text(
                    'Thống kê',
                    style: R.styles.heading2(
                      color: AppColors.black,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  // Time period selector
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.greyLight,
                      borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadiusXLarge),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _buildPeriodButton('Tuần', 0)),
                        Expanded(child: _buildPeriodButton('Tháng', 1)),
                        Expanded(child: _buildPeriodButton('Năm', 2)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Statistics Cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Tỷ lệ hoàn thành',
                                  '${_completionRate.clamp(0.0, 100.0).toInt()}%',
                                  AppColors.primary,
                                  Icons.check_circle_outline,
                                ),
                              ),
                              const SizedBox(
                                  width: AppDimensions.paddingMedium),
                              Expanded(
                                child: _buildStatCard(
                                  'Việc quá hạn',
                                  '$_overdueTasks',
                                  AppColors.error,
                                  Icons.warning_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.paddingMedium),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Điểm hiệu suất',
                                  _performanceScore.toStringAsFixed(1),
                                  const Color(0xFFFF9500),
                                  Icons.star_outline,
                                ),
                              ),
                              const SizedBox(
                                  width: AppDimensions.paddingMedium),
                              Expanded(
                                child: _buildStatCard(
                                  'Trạng thái',
                                  statusText,
                                  statusColor,
                                  statusIcon,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.paddingLarge),

                          // Job Classification Card
                          _buildCard(
                            title: 'Phân loại công việc',
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: _buildDonutChart(),
                                  ),
                                ),
                                const SizedBox(
                                    height: AppDimensions.paddingLarge),
                                // Legend
                                _categoryData.isEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(
                                            AppDimensions.paddingLarge),
                                        child: Center(
                                          child: Text(
                                            'Chưa có dữ liệu phân loại',
                                            style: R.styles.body(
                                              size: 14,
                                              color: AppColors.grey,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: _categoryData.map((data) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: AppDimensions
                                                    .paddingMedium),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 12,
                                                  height: 12,
                                                  decoration: BoxDecoration(
                                                    color: data.color,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    width: AppDimensions
                                                        .paddingSmall),
                                                Text(
                                                  '${data.name} (${data.percentage}%)',
                                                  style: R.styles.body(
                                                    size: 14,
                                                    color: AppColors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingLarge),

                          // Completed Tasks Card
                          _buildCard(
                            title: 'Công việc hoàn thành',
                            child: SizedBox(
                              height: 200,
                              child: _buildBarChart(),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingLarge),

                          // Performance Trend Card
                          _buildCard(
                            title: 'Xu hướng hiệu suất',
                            child: SizedBox(
                              height: 200,
                              child: _buildLineChart(),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingLarge),

                          // AI Analysis Section
                          _buildAIAnalysisCard(),
                          const SizedBox(height: AppDimensions.paddingLarge),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, int index) {
    final isSelected = _selectedPeriod == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = index;
        });
        _loadStatistics(); // Reload data when period changes
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXLarge),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: R.styles.body(
            size: 14,
            weight: isSelected ? FontWeight.w900 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.greyDark,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppDimensions.paddingSmall),
              Expanded(
                child: Text(
                  title,
                  style: R.styles.body(
                    size: 14,
                    color: AppColors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            value,
            style: R.styles.heading3(
              color: color,
              weight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget hiển thị phân tích AI với animation
  Widget _buildAIAnalysisCard() {
    return _buildCard(
      title: 'Phân tích từ chuyên gia AI',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isAnalyzing)
            // Animation "Phân tích dữ liệu"
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusMedium,
                    ),
                  ),
                  child: Row(
                    children: [
                      RotationTransition(
                        turns: _animation,
                        child: Icon(
                          Icons.psychology_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingSmall),
                      Expanded(
                        child: Text(
                          'Phân tích dữ liệu${_getLoadingDots()}',
                          style: R.styles.body(
                            size: 14,
                            color: AppColors.primary,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          else if (_aiAnalysis.isNotEmpty)
            // Hiển thị kết quả phân tích
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.greyLight.withOpacity(0.3),
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusMedium,
                ),
                border: Border.all(
                  color: AppColors.primaryLight.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: AppDimensions.paddingSmall),
                      Text(
                        'Phân tích chuyên sâu',
                        style: R.styles.body(
                          size: 14,
                          weight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  Text(
                    _aiAnalysis,
                    style: R.styles
                        .body(
                          size: 14,
                          color: AppColors.greyDark,
                        )
                        .copyWith(height: 1.6),
                  ),
                ],
              ),
            )
          else
            // Empty state
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusMedium,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.psychology_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  Expanded(
                    child: Text(
                      'Đang tải phân tích...',
                      style: R.styles.body(
                        size: 14,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Tạo loading dots animation
  String _getLoadingDots() {
    final dotCount = ((_animation.value * 3).floor() % 4);
    return '.' * dotCount;
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: R.styles.body(
              size: 16,
              weight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          child,
        ],
      ),
    );
  }

  Widget _buildDonutChart() {
    if (_categoryData.isEmpty) {
      return Center(
        child: Text(
          'Chưa có dữ liệu',
          style: R.styles.body(
            size: 14,
            color: AppColors.grey,
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sectionsSpace: 0,
            centerSpaceRadius: 70,
            sections: _categoryData.map((data) {
              return PieChartSectionData(
                value: data.percentage.toDouble(),
                color: data.color,
                title: '',
                radius: 30,
              );
            }).toList(),
            pieTouchData: PieTouchData(
              enabled: true,
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_completedTasks',
              style: R.styles.heading1(
                color: AppColors.black,
                weight: FontWeight.w900,
              ),
            ),
            Text(
              'Đã hoàn thành',
              style: R.styles.body(
                size: 14,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    if (_weeklyData.isEmpty) {
      return Center(
        child: Text(
          'Chưa có dữ liệu',
          style: R.styles.body(
            size: 14,
            color: AppColors.grey,
          ),
        ),
      );
    }

    final maxValue =
        _weeklyData.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    // Calculate current index based on selected period
    int? currentIndex;
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case 0: // Tuần (Week)
        // Find index of today in the week (0-6, where 0 = Monday)
        final daysFromMonday = (now.weekday - 1) % 7;
        currentIndex = daysFromMonday;
        break;
      case 1: // Tháng (Month)
        // Find index of current week in the month
        final weeks = <List<int>>[];
        int currentWeek = 0;
        for (int day = 1;
            day <= DateTime(now.year, now.month + 1, 0).day;
            day++) {
          final date = DateTime(now.year, now.month, day);
          final weekday = date.weekday;
          if (weekday == 1 || weeks.isEmpty) {
            weeks.add([]);
            currentWeek = weeks.length - 1;
          }
          weeks[currentWeek].add(day);
          // Check if today is in this week
          if (date.day == now.day) {
            currentIndex = currentWeek;
            break;
          }
        }
        break;
      case 2: // Năm (Year)
        // Find index of current month (0-11)
        currentIndex = now.month - 1;
        break;
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue > 0 ? maxValue * 1.2 : 10,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rodIndex, rodStackIndex) {
              final index = groupIndex;
              if (index >= 0 && index < _weeklyData.length) {
                final data = _weeklyData[index];
                return BarTooltipItem(
                  '${data.day}: ${data.value} tasks',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }
              return null;
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < _weeklyData.length) {
                  final isCurrent =
                      currentIndex != null && index == currentIndex;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _weeklyData[index].day,
                      style: R.styles.body(
                        size: 12,
                        weight: isCurrent ? FontWeight.w900 : FontWeight.w400,
                        color: isCurrent ? AppColors.primary : AppColors.grey,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: _weeklyData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final isHighlighted = currentIndex != null && index == currentIndex;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data.value.toDouble(),
                color:
                    isHighlighted ? AppColors.primary : const Color(0xFFDBE9F9),
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLineChart() {
    if (_performanceTrend.isEmpty) {
      return Center(
        child: Text(
          'Chưa có dữ liệu',
          style: R.styles.body(
            size: 14,
            color: AppColors.grey,
          ),
        ),
      );
    }

    final maxValue = _performanceTrend.reduce((a, b) => a > b ? a : b);
    final minValue = _performanceTrend.reduce((a, b) => a < b ? a : b);

    List<String> labels = [];
    if (_selectedPeriod == 0) {
      labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    } else if (_selectedPeriod == 1) {
      labels = List.generate(_performanceTrend.length, (i) => 'Tuần ${i + 1}');
    } else if (_selectedPeriod == 2) {
      labels = [
        'T1',
        'T2',
        'T3',
        'T4',
        'T5',
        'T6',
        'T7',
        'T8',
        'T9',
        'T10',
        'T11',
        'T12'
      ];
    }

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => AppColors.primary,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index >= 0 && index < _performanceTrend.length) {
                  final value = _performanceTrend[index];
                  final label = labels.length > index ? labels[index] : '';
                  return LineTooltipItem(
                    '$label\nĐiểm: ${value.toStringAsFixed(1)}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }
                return const LineTooltipItem('', TextStyle());
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.greyLight,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 &&
                    index < labels.length &&
                    index < _performanceTrend.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[index],
                      style: R.styles.body(
                        size: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: AppColors.greyLight, width: 1),
          ),
        ),
        minX: 0,
        maxX: (_performanceTrend.length - 1).toDouble(),
        minY: minValue > 0 ? minValue - 1 : 0,
        maxY: maxValue > 0 ? maxValue + 1 : 10,
        lineBarsData: [
          LineChartBarData(
            spots: _performanceTrend.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value);
            }).toList(),
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primaryLight.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryData {
  final String name;
  final int count;
  final int percentage;
  final Color color;

  CategoryData({
    required this.name,
    required this.count,
    required this.percentage,
    required this.color,
  });
}

class BarData {
  final String day;
  final int value;

  BarData({required this.day, required this.value});
}

Widget _buildTooltip(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.paddingMedium,
      vertical: AppDimensions.paddingSmall,
    ),
    decoration: BoxDecoration(
      color: AppColors.black.withOpacity(0.8),
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
    ),
    child: Text(
      text,
      style: R.styles.body(
        size: 12,
        color: AppColors.white,
        weight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    ),
  );
}
