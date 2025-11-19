import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import '../services/category_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _taskService = TaskService();
  final _categoryService = CategoryService();

  int _selectedPeriod = 1; // 0: Tuần, 1: Tháng, 2: Năm
  bool _isLoading = true;

  // Statistics data from database
  double _completionRate = 0.0;
  int _overdueTasks = 0;
  double _performanceScore = 0.0;
  int _totalTasks = 0;
  List<CategoryData> _categoryData = [];
  List<BarData> _weeklyData = [];
  List<double> _performanceTrend = [];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load all tasks
      final allTasks = await _taskService.getTasks();
      final overdueTasksList = await _taskService.getOverdueTasks();

      // Load categories
      final categories = await _categoryService.getCategories();

      // Calculate statistics
      _totalTasks = allTasks.length;
      final completedTasks =
          allTasks.where((t) => t.status == TaskStatus.completed).length;
      _overdueTasks = overdueTasksList.length;

      // Calculate completion rate
      _completionRate =
          _totalTasks > 0 ? (completedTasks / _totalTasks) * 100 : 0.0;

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
      for (var task in allTasks) {
        if (task.categoryId != null) {
          categoryMap[task.categoryId!] =
              (categoryMap[task.categoryId!] ?? 0) + 1;
        }
      }

      int colorIndex = 0;
      for (var category in categories) {
        final count = categoryMap[category.id] ?? 0;
        if (count > 0) {
          final percentage =
              _totalTasks > 0 ? ((count / _totalTasks) * 100).round() : 0;
          _categoryData.add(CategoryData(
            name: category.name,
            count: count,
            percentage: percentage,
            color: categoryColors[colorIndex % categoryColors.length],
          ));
          colorIndex++;
        }
      }

      // Calculate weekly completion data
      _calculateWeeklyData(allTasks);

      // Calculate performance trend (last 7 days)
      _calculatePerformanceTrend(allTasks);

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

  void _calculateWeeklyData(List<Task> tasks) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    final daysOfWeek = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    _weeklyData = [];

    for (int i = 0; i < 7; i++) {
      final dayStart =
          DateTime(weekStart.year, weekStart.month, weekStart.day + i);
      final dayEnd = dayStart.add(const Duration(days: 1));

      // Count tasks that were completed on this day
      // Since Task model doesn't have completedAt, we'll use dueDate for completed tasks
      // or count tasks that have dueDate on this day and are completed
      final completedCount = tasks.where((task) {
        if (task.status != TaskStatus.completed) return false;
        // Use dueDate as approximation, or count all completed tasks with dueDate in this range
        if (task.dueDate != null) {
          final dueDate = task.dueDate!;
          return dueDate.isAfter(dayStart.subtract(const Duration(days: 1))) &&
              dueDate.isBefore(dayEnd);
        }
        return false;
      }).length;

      _weeklyData.add(BarData(
        day: daysOfWeek[i],
        value: completedCount,
      ));
    }
  }

  void _calculatePerformanceTrend(List<Task> tasks) {
    final now = DateTime.now();
    _performanceTrend = [];

    // Calculate performance for last 7 days
    for (int i = 6; i >= 0; i--) {
      final dayStart = DateTime(now.year, now.month, now.day - i);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayTasks = tasks.where((task) {
        if (task.dueDate == null) return false;
        final dueDate = task.dueDate!;
        return dueDate.isAfter(dayStart) && dueDate.isBefore(dayEnd);
      }).toList();

      if (dayTasks.isEmpty) {
        _performanceTrend.add(0.0);
      } else {
        final completed =
            dayTasks.where((t) => t.status == TaskStatus.completed).length;
        final score = (completed / dayTasks.length) * 10;
        _performanceTrend.add(score);
      }
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
                                  '${_completionRate.toInt()}%',
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
                          _buildCard(
                            title: 'Phân tích từ chuyên gia AI',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(
                                      AppDimensions.paddingMedium),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primaryLight.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                        AppDimensions.borderRadiusMedium),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.psychology_outlined,
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                                      const SizedBox(
                                          width: AppDimensions.paddingSmall),
                                      Expanded(
                                        child: Text(
                                          'Đang phân tích dữ liệu...',
                                          style: R.styles.body(
                                            size: 14,
                                            color: AppColors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                    height: AppDimensions.paddingMedium),
                                Text(
                                  'Nhấn để xem phân tích chi tiết',
                                  style: R.styles.body(
                                    size: 14,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_totalTasks',
              style: R.styles.heading1(
                color: AppColors.black,
                weight: FontWeight.w900,
              ),
            ),
            Text(
              'Công việc',
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
    final todayIndex = DateTime.now().weekday - 1; // 0 = Monday, 6 = Sunday

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue > 0 ? maxValue * 1.2 : 10,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < _weeklyData.length) {
                  final isCurrentDay = index == todayIndex;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _weeklyData[index].day,
                      style: R.styles.body(
                        size: 12,
                        weight:
                            isCurrentDay ? FontWeight.w900 : FontWeight.w400,
                        color:
                            isCurrentDay ? AppColors.primary : AppColors.grey,
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
          final isHighlighted = index == todayIndex;
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
    final daysOfWeek = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return LineChart(
      LineChartData(
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
                if (index >= 0 && index < daysOfWeek.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      daysOfWeek[index],
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
        maxX: 6,
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
