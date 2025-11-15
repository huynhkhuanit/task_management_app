import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedPeriod = 1; // 0: Tuần, 1: Tháng, 2: Năm

  // Sample data
  final double completionRate = 85.0;
  final int overdueTasks = 3;
  final double performanceScore = 9.2;
  final int totalTasks = 25;

  // Category distribution data
  final List<CategoryData> categoryData = [
    CategoryData(
        name: 'Công việc', count: 12, percentage: 50, color: AppColors.primary),
    CategoryData(
        name: 'Cá nhân',
        count: 8,
        percentage: 30,
        color: const Color(0xFF10B981)),
    CategoryData(
        name: 'Học tập',
        count: 5,
        percentage: 20,
        color: const Color(0xFFFF9500)),
  ];

  // Weekly completion data
  final List<BarData> weeklyData = [
    BarData(day: 'T2', value: 5),
    BarData(day: 'T3', value: 7),
    BarData(day: 'T4', value: 12),
    BarData(day: 'T5', value: 8),
    BarData(day: 'T6', value: 6),
    BarData(day: 'T7', value: 4),
    BarData(day: 'CN', value: 3),
  ];

  // Performance trend data
  final List<double> performanceTrend = [7.5, 8.0, 8.5, 9.0, 8.8, 9.2, 9.0];

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
              child: SingleChildScrollView(
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
                            '${completionRate.toInt()}%',
                            AppColors.primary,
                            Icons.check_circle_outline,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingMedium),
                        Expanded(
                          child: _buildStatCard(
                            'Việc quá hạn',
                            '$overdueTasks',
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
                            performanceScore.toStringAsFixed(1),
                            const Color(0xFFFF9500),
                            Icons.star_outline,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingMedium),
                        const Expanded(child: SizedBox()),
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
                          const SizedBox(height: AppDimensions.paddingLarge),
                          // Legend
                          Column(
                            children: categoryData.map((data) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppDimensions.paddingMedium),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                        width: AppDimensions.paddingSmall),
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
                              color: AppColors.primaryLight.withOpacity(0.1),
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
                          const SizedBox(height: AppDimensions.paddingMedium),
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
                    size: 12,
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
            style: R.styles.heading2(
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
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sectionsSpace: 0,
            centerSpaceRadius: 70,
            sections: categoryData.map((data) {
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
              '$totalTasks',
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
    final maxValue =
        weeklyData.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < weeklyData.length) {
                  final isCurrentDay = index == 2; // T4 is current day
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      weeklyData[index].day,
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
        barGroups: weeklyData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final isHighlighted = index == 2; // T4 is highlighted
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
    final maxValue = performanceTrend.reduce((a, b) => a > b ? a : b);
    final minValue = performanceTrend.reduce((a, b) => a < b ? a : b);

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
                if (index >= 0 && index < weeklyData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      weeklyData[index].day,
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
        minY: minValue - 1,
        maxY: maxValue + 1,
        lineBarsData: [
          LineChartBarData(
            spots: performanceTrend.asMap().entries.map((entry) {
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
