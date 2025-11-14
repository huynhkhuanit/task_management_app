import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../models/task_model.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _projectController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  TaskPriority _selectedPriority = TaskPriority.medium;

  @override
  void dispose() {
    _titleController.dispose();
    _projectController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return const Color(0xFFFF9500);
      case TaskPriority.medium:
        return const Color(0xFF34C759);
      case TaskPriority.urgent:
        return const Color(0xFFFF3B30);
      case TaskPriority.low:
        return const Color(0xFF8E8E93);
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

  void _addTask() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tiêu đề công việc'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // TODO: Save task to database/state management
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Thêm công việc mới',
          style: R.styles.heading2(
            color: AppColors.black,
            weight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Title
              Text(
                'Tiêu đề công việc',
                style: R.styles.body(
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusMedium,
                  ),
                  border: Border.all(
                    color: AppColors.greyLight,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _titleController,
                  style: R.styles.body(
                    size: 16,
                    color: AppColors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Nhập tiêu đề công việc',
                    hintStyle: R.styles.body(
                      size: 16,
                      color: AppColors.grey,
                    ),
                    prefixIcon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.grey,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.all(
                      AppDimensions.paddingMedium,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLarge),

              // Date
              Text(
                'Ngày',
                style: R.styles.body(
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusMedium,
                    ),
                    border: Border.all(
                      color: AppColors.greyLight,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: AppDimensions.paddingMedium),
                      Expanded(
                        child: Text(
                          _selectedDate == null
                              ? 'Chọn ngày'
                              : _formatDate(_selectedDate),
                          style: R.styles.body(
                            size: 16,
                            color: _selectedDate == null
                                ? AppColors.grey
                                : AppColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLarge),

              // Time
              Text(
                'Giờ',
                style: R.styles.body(
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              GestureDetector(
                onTap: () => _selectTime(context),
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusMedium,
                    ),
                    border: Border.all(
                      color: AppColors.greyLight,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_outlined,
                        color: AppColors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: AppDimensions.paddingMedium),
                      Expanded(
                        child: Text(
                          _selectedTime == null
                              ? 'Chọn giờ'
                              : _formatTime(_selectedTime),
                          style: R.styles.body(
                            size: 16,
                            color: _selectedTime == null
                                ? AppColors.grey
                                : AppColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLarge),

              // Priority
              Text(
                'Mức độ ưu tiên',
                style: R.styles.body(
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              Row(
                children: [
                  Expanded(
                    child: _buildPriorityButton(
                      TaskPriority.low,
                      'Thấp',
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  Expanded(
                    child: _buildPriorityButton(
                      TaskPriority.medium,
                      'Trung bình',
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  Expanded(
                    child: _buildPriorityButton(
                      TaskPriority.high,
                      'Cao',
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  Expanded(
                    child: _buildPriorityButton(
                      TaskPriority.urgent,
                      'Khẩn cấp',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingLarge),

              // Project
              Text(
                'Dự án',
                style: R.styles.body(
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusMedium,
                  ),
                  border: Border.all(
                    color: AppColors.greyLight,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _projectController,
                  style: R.styles.body(
                    size: 16,
                    color: AppColors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Nhập tên dự án',
                    hintStyle: R.styles.body(
                      size: 16,
                      color: AppColors.grey,
                    ),
                    prefixIcon: const Icon(
                      Icons.folder_outlined,
                      color: AppColors.grey,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.all(
                      AppDimensions.paddingMedium,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXLarge),

              // Add Task Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingMedium,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadiusMedium,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Thêm công việc',
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
      ),
    );
  }

  Widget _buildPriorityButton(TaskPriority priority, String label) {
    final isSelected = _selectedPriority == priority;
    final color = _getPriorityColor(priority);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPriority = priority;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingSmall,
          horizontal: AppDimensions.paddingXSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : AppColors.white,
          borderRadius: BorderRadius.circular(
            AppDimensions.borderRadiusMedium,
          ),
          border: Border.all(
            color: isSelected ? color : AppColors.greyLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: R.styles.caption(
                color: isSelected ? color : AppColors.grey,
                weight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

