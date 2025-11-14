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
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  TaskPriority _selectedPriority = TaskPriority.low;
  bool _reminderEnabled = true;
  final List<String> _subTasks = [];
  final List<TextEditingController> _subTaskControllers = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (var controller in _subTaskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDateAndTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime ?? TimeOfDay.now(),
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
      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
      }
    }
  }

  String _getDateDisplay() {
    if (_selectedDate == null) return 'Hôm nay';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected =
        DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);

    if (selected == today) {
      return 'Hôm nay';
    } else if (selected == today.add(const Duration(days: 1))) {
      return 'Ngày mai';
    } else {
      return '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
    }
  }

  String _getTimeDisplay() {
    if (_selectedTime == null) return '10:00 AM';
    final hour = _selectedTime!.hour;
    final minute = _selectedTime!.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AppColors.primary;
      case TaskPriority.medium:
        return const Color(0xFFFF9500);
      case TaskPriority.high:
        return const Color(0xFFFF3B30);
      case TaskPriority.urgent:
        return const Color(0xFFFF3B30);
    }
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Thấp';
      case TaskPriority.medium:
        return 'Trung bình';
      case TaskPriority.high:
        return 'Cao';
      case TaskPriority.urgent:
        return 'Khẩn cấp';
    }
  }

  void _addSubTask() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Thêm công việc con'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Nhập tên công việc con',
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _subTasks.add(value);
                  _subTaskControllers.add(TextEditingController(text: value));
                });
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.dispose();
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _subTasks.add(controller.text);
                    _subTaskControllers
                        .add(TextEditingController(text: controller.text));
                  });
                  controller.dispose();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  void _saveTask() {
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
            controller: controller,
            maxLines: maxLines,
            style: R.styles.body(
              size: 16,
              color: AppColors.black,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: R.styles.body(
                size: 16,
                color: AppColors.grey,
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
      ],
    );
  }

  Widget _buildTaskDetailItem({
    required IconData icon,
    required String label,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingMedium,
          horizontal: AppDimensions.paddingMedium,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.grey, size: 20),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: Text(
                label,
                style: R.styles.body(
                  size: 16,
                  color: AppColors.black,
                ),
              ),
            ),
            trailing,
            if (onTap != null)
              const Icon(
                Icons.chevron_right,
                color: AppColors.grey,
                size: 20,
              ),
          ],
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
          icon: const Icon(Icons.close, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Công việc mới',
          style: R.styles.heading2(
            color: AppColors.black,
            weight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task Title
                    _buildTextField(
                      label: 'Tiêu đề công việc',
                      controller: _titleController,
                      hintText: 'Nhập tiêu đề công việc của bạn',
                    ),
                    const SizedBox(height: AppDimensions.paddingLarge),

                    // Description
                    _buildTextField(
                      label: 'Mô tả',
                      controller: _descriptionController,
                      hintText: 'Thêm chi tiết về công việc của bạn',
                      maxLines: 4,
                    ),
                    const SizedBox(height: AppDimensions.paddingLarge),

                    // Task Details Card
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadiusLarge,
                        ),
                        border: Border.all(
                          color: AppColors.greyLight,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Category
                          _buildTaskDetailItem(
                            icon: Icons.layers_outlined,
                            label: 'Danh mục',
                            trailing: Text(
                              _selectedCategory ?? 'Công việc',
                              style: R.styles.body(
                                size: 16,
                                color: AppColors.black,
                              ),
                            ),
                            onTap: () {
                              // TODO: Show category picker
                              setState(() {
                                _selectedCategory = 'Công việc';
                              });
                            },
                          ),
                          Divider(height: 1, color: AppColors.greyLight),

                          // Date & Time
                          _buildTaskDetailItem(
                            icon: Icons.calendar_today_outlined,
                            label: 'Ngày & Giờ',
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getDateDisplay(),
                                  style: R.styles.body(
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getTimeDisplay(),
                                  style: R.styles.body(
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => _selectDateAndTime(context),
                          ),
                          Divider(height: 1, color: AppColors.greyLight),

                          // Priority
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppDimensions.paddingMedium,
                              horizontal: AppDimensions.paddingMedium,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.priority_high,
                                  color: AppColors.grey,
                                  size: 20,
                                ),
                                const SizedBox(
                                    width: AppDimensions.paddingMedium),
                                Expanded(
                                  child: Text(
                                    'Mức độ ưu tiên',
                                    style: R.styles.body(
                                      size: 16,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: AppDimensions.paddingMedium,
                              right: AppDimensions.paddingMedium,
                              bottom: AppDimensions.paddingMedium,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildPriorityPillButton(
                                    TaskPriority.low,
                                    'Thấp',
                                  ),
                                ),
                                const SizedBox(
                                    width: AppDimensions.paddingSmall),
                                Expanded(
                                  child: _buildPriorityPillButton(
                                    TaskPriority.medium,
                                    'Trung bình',
                                  ),
                                ),
                                const SizedBox(
                                    width: AppDimensions.paddingSmall),
                                Expanded(
                                  child: _buildPriorityPillButton(
                                    TaskPriority.high,
                                    'Cao',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 1, color: AppColors.greyLight),

                          // Attach file
                          _buildTaskDetailItem(
                            icon: Icons.attach_file,
                            label: 'Đính kèm tệp',
                            trailing: const SizedBox.shrink(),
                            onTap: () {
                              // TODO: Show file picker
                            },
                          ),
                          Divider(height: 1, color: AppColors.greyLight),

                          // Set Reminder
                          _buildTaskDetailItem(
                            icon: Icons.notifications_outlined,
                            label: 'Đặt nhắc nhở',
                            trailing: Switch(
                              value: _reminderEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _reminderEnabled = value;
                                });
                              },
                              activeColor: AppColors.primary,
                              inactiveThumbColor: AppColors.primary,
                              inactiveTrackColor: AppColors.greyLight,
                              trackOutlineColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  return Colors.transparent;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingLarge),

                    // Sub-tasks
                    Text(
                      'Công việc con',
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
                      child: Column(
                        children: [
                          if (_subTasks.isEmpty) ...[
                            _buildSubTaskItem(
                                'Công việc con đầu tiên', false, 0,
                                isDefault: true),
                            _buildSubTaskItem('Công việc con thứ hai', false, 1,
                                isDefault: true),
                          ] else
                            ...List.generate(_subTasks.length, (index) {
                              return _buildSubTaskItem(
                                _subTasks[index],
                                false,
                                index,
                              );
                            }),
                          InkWell(
                            onTap: _addSubTask,
                            child: Padding(
                              padding: const EdgeInsets.all(
                                AppDimensions.paddingMedium,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(
                                      width: AppDimensions.paddingSmall),
                                  Text(
                                    'Thêm công việc con',
                                    style: R.styles.body(
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
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

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingLarge,
                vertical: AppDimensions.paddingMedium,
              ),
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
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingSmall,
                        ),
                        minimumSize: const Size(0, 44),
                        side: const BorderSide(
                          color: AppColors.greyLight,
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
                  const SizedBox(width: AppDimensions.paddingMedium),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saveTask,
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
                        'Lưu',
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
    );
  }

  Widget _buildPriorityPillButton(TaskPriority priority, String label) {
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
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: R.styles.caption(
            color: isSelected ? AppColors.white : color,
            weight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSubTaskItem(String text, bool isChecked, int index,
      {bool isDefault = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.paddingSmall,
        horizontal: AppDimensions.paddingMedium,
      ),
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            onChanged: (value) {
              // TODO: Handle checkbox change
            },
            activeColor: AppColors.primary,
          ),
          Expanded(
            child: Text(
              text,
              style: R.styles.body(
                size: 16,
                color: AppColors.black,
              ),
            ),
          ),
          if (!isDefault)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: AppColors.grey,
              onPressed: () {
                setState(() {
                  _subTasks.removeAt(index);
                  _subTaskControllers[index].dispose();
                  _subTaskControllers.removeAt(index);
                });
              },
            ),
        ],
      ),
    );
  }
}
