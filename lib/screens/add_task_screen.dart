import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../models/task_model.dart';
import '../utils/navigation_helper.dart';
import 'categories_screen.dart';

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
  final List<PlatformFile> _attachedFiles = [];
  bool _filesExpanded = false;

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

  Future<void> _showCategoryPicker() async {
    final result = await NavigationHelper.pushSlideTransition<String>(
      context,
      CategoriesScreen(
        selectedCategoryName: _selectedCategory,
        onCategorySelected: (categoryName) {
          Navigator.of(context).pop(categoryName);
        },
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCategory = result;
      });
    }
  }

  Future<void> _showDateTimePicker() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CustomDateTimePicker(
        initialDate: _selectedDate ?? DateTime.now(),
        initialTime: _selectedTime ?? const TimeOfDay(hour: 10, minute: 0),
        onDateSelected: (date) {
          setState(() {
            _selectedDate = date;
          });
        },
        onTimeSelected: (time) {
          setState(() {
            _selectedTime = time;
          });
        },
      ),
    );
  }

  Future<void> _pickFiles() async {
    try {
      // Try to pick files with custom extensions for better compatibility
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'jpg',
          'jpeg',
          'png',
          'gif',
          'txt'
        ],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _attachedFiles.addAll(result.files);
          _filesExpanded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        // Show user-friendly error message
        final errorMessage = e.toString().contains('MissingPluginException')
            ? 'Chức năng chọn file chưa được hỗ trợ. Vui lòng khởi động lại ứng dụng hoặc cài đặt lại.'
            : 'Lỗi khi chọn file: ${e.toString()}';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
      if (_attachedFiles.isEmpty) {
        _filesExpanded = false;
      }
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _getFileIcon(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddSubTaskModal(
        onAdd: (value) {
          if (value.trim().isNotEmpty && mounted) {
            setState(() {
              _subTasks.add(value.trim());
              _subTaskControllers.add(
                TextEditingController(text: value.trim()),
              );
            });
          }
        },
      ),
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
            size: 18,
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
                            onTap: _showCategoryPicker,
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
                            onTap: _showDateTimePicker,
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
                            trailing: Icon(
                              _filesExpanded
                                  ? Icons.keyboard_arrow_down
                                  : Icons.chevron_right,
                              color: AppColors.grey,
                              size: 20,
                            ),
                            onTap: () {
                              if (_attachedFiles.isEmpty) {
                                _pickFiles();
                              } else {
                                setState(() {
                                  _filesExpanded = !_filesExpanded;
                                });
                              }
                            },
                          ),
                          if (_filesExpanded && _attachedFiles.isNotEmpty) ...[
                            Divider(height: 1, color: AppColors.greyLight),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.paddingMedium,
                                horizontal: AppDimensions.paddingMedium,
                              ),
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _attachedFiles.length,
                                itemBuilder: (context, index) {
                                  final file = _attachedFiles[index];
                                  return Container(
                                    width: 80,
                                    margin: const EdgeInsets.only(
                                      right: AppDimensions.paddingSmall,
                                    ),
                                    child: Column(
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: AppColors.greyLight
                                                    .withOpacity(0.3),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  AppDimensions
                                                      .borderRadiusMedium,
                                                ),
                                              ),
                                              child: Icon(
                                                _getFileIcon(file.extension),
                                                color: AppColors.primary,
                                                size: 30,
                                              ),
                                            ),
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              child: GestureDetector(
                                                onTap: () => _removeFile(index),
                                                child: Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: AppColors.error,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: AppColors.white,
                                                    size: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Expanded(
                                          child: Text(
                                            file.name.length > 10
                                                ? '${file.name.substring(0, 10)}...'
                                                : file.name,
                                            style: R.styles.body(
                                              size: 10,
                                              color: AppColors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          _formatFileSize(file.size),
                                          style: R.styles.caption(
                                            color: AppColors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            InkWell(
                              onTap: _pickFiles,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.paddingMedium,
                                  vertical: AppDimensions.paddingSmall,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                    const SizedBox(
                                        width: AppDimensions.paddingSmall),
                                    Text(
                                      'Thêm file',
                                      style: R.styles.body(
                                        size: 14,
                                        color: AppColors.primary,
                                        weight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          Divider(height: 1, color: AppColors.greyLight),

                          // Set Reminder
                          _buildTaskDetailItem(
                            icon: Icons.notifications_outlined,
                            label: 'Đặt nhắc nhở',
                            trailing: _CustomAnimatedSwitch(
                              value: _reminderEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _reminderEnabled = value;
                                });
                              },
                            ),
                            onTap: () {
                              setState(() {
                                _reminderEnabled = !_reminderEnabled;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingLarge),

                    // Sub-tasks
                    Text(
                      'Công việc con',
                      style: R.styles.body(
                        size: 18,
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
            checkColor: AppColors.white,
            fillColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return AppColors.primary;
                }
                return AppColors.white;
              },
            ),
            side: BorderSide(
              color: AppColors.greyLight,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadiusSmall,
              ),
            ),
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

class _CustomDateTimePicker extends StatefulWidget {
  final DateTime initialDate;
  final TimeOfDay initialTime;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<TimeOfDay> onTimeSelected;

  const _CustomDateTimePicker({
    required this.initialDate,
    required this.initialTime,
    required this.onDateSelected,
    required this.onTimeSelected,
  });

  @override
  State<_CustomDateTimePicker> createState() => _CustomDateTimePickerState();
}

class _CustomDateTimePickerState extends State<_CustomDateTimePicker> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _periodController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedTime = widget.initialTime;

    // Initialize hour controller (1-12)
    final hour12 = widget.initialTime.hour == 0
        ? 12
        : (widget.initialTime.hour > 12
            ? widget.initialTime.hour - 12
            : widget.initialTime.hour);
    _hourController = FixedExtentScrollController(
      initialItem: hour12 - 1, // 0-based index
    );

    _minuteController = FixedExtentScrollController(
      initialItem: widget.initialTime.minute,
    );

    _periodController = FixedExtentScrollController(
      initialItem: widget.initialTime.hour >= 12 ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  void _updateTime() {
    final hour = _hourController.selectedItem + 1;
    final minute = _minuteController.selectedItem;
    final isPM = _periodController.selectedItem == 1;
    final newHour =
        isPM ? (hour == 12 ? 12 : hour + 12) : (hour == 12 ? 0 : hour);

    setState(() {
      _selectedTime = TimeOfDay(hour: newHour, minute: minute);
    });
    widget.onTimeSelected(_selectedTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
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
          // Title
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Chọn ngày & giờ',
                    style: R.styles.heading2(
                      color: AppColors.black,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.onDateSelected(_selectedDate);
                    widget.onTimeSelected(_selectedTime);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Xong',
                    style: R.styles.body(
                      size: 16,
                      weight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Date Picker
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingLarge,
                    ),
                    child: _CustomDatePicker(
                      selectedDate: _selectedDate,
                      onDateSelected: (date) {
                        setState(() {
                          _selectedDate = date;
                        });
                        widget.onDateSelected(date);
                      },
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  // Time Picker
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingLarge,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Giờ',
                          style: R.styles.body(
                            size: 16,
                            weight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingMedium),
                        SizedBox(
                          height: 200,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Hour picker
                              Expanded(
                                child: ListWheelScrollView.useDelegate(
                                  controller: _hourController,
                                  itemExtent: 50,
                                  physics: const FixedExtentScrollPhysics(),
                                  onSelectedItemChanged: (index) =>
                                      _updateTime(),
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    builder: (context, index) {
                                      final hour = index + 1;
                                      final isSelected =
                                          _hourController.selectedItem == index;
                                      return Center(
                                        child: Text(
                                          hour.toString().padLeft(2, '0'),
                                          style: R.styles.body(
                                            size: isSelected ? 24 : 18,
                                            weight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w400,
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.grey,
                                          ),
                                        ),
                                      );
                                    },
                                    childCount: 12,
                                  ),
                                ),
                              ),
                              Text(
                                ':',
                                style: R.styles.body(
                                  size: 24,
                                  weight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                              ),
                              // Minute picker
                              Expanded(
                                child: ListWheelScrollView.useDelegate(
                                  controller: _minuteController,
                                  itemExtent: 50,
                                  physics: const FixedExtentScrollPhysics(),
                                  onSelectedItemChanged: (index) =>
                                      _updateTime(),
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    builder: (context, index) {
                                      final minute = index;
                                      final isSelected =
                                          _minuteController.selectedItem ==
                                              index;
                                      return Center(
                                        child: Text(
                                          minute.toString().padLeft(2, '0'),
                                          style: R.styles.body(
                                            size: isSelected ? 24 : 18,
                                            weight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w400,
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.grey,
                                          ),
                                        ),
                                      );
                                    },
                                    childCount: 60,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                  width: AppDimensions.paddingMedium),
                              // AM/PM picker
                              SizedBox(
                                width: 80,
                                child: ListWheelScrollView.useDelegate(
                                  controller: _periodController,
                                  itemExtent: 50,
                                  physics: const FixedExtentScrollPhysics(),
                                  onSelectedItemChanged: (index) =>
                                      _updateTime(),
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    builder: (context, index) {
                                      final period = index == 0 ? 'AM' : 'PM';
                                      final isSelected =
                                          _periodController.selectedItem ==
                                              index;
                                      return Center(
                                        child: Text(
                                          period,
                                          style: R.styles.body(
                                            size: isSelected ? 20 : 16,
                                            weight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w400,
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.grey,
                                          ),
                                        ),
                                      );
                                    },
                                    childCount: 2,
                                  ),
                                ),
                              ),
                            ],
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
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);

    if (selected == today) {
      return 'Hôm nay';
    } else if (selected == today.add(const Duration(days: 1))) {
      return 'Ngày mai';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _AddSubTaskModal extends StatefulWidget {
  final Function(String) onAdd;

  const _AddSubTaskModal({
    required this.onAdd,
  });

  @override
  State<_AddSubTaskModal> createState() => _AddSubTaskModalState();
}

class _AddSubTaskModalState extends State<_AddSubTaskModal> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleAdd() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onAdd(_controller.text.trim());
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
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
            // Title
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Thêm công việc con',
                      style: R.styles.heading2(
                        color: AppColors.black,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.grey),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            // Input field
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingLarge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tên công việc con',
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
                      controller: _controller,
                      autofocus: true,
                      style: R.styles.body(
                        size: 16,
                        color: AppColors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Nhập tên công việc con',
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
                      onSubmitted: (_) => _handleAdd(),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingLarge),
                ],
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
                      onPressed: _handleAdd,
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
                        'Thêm',
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
}

class _CustomAnimatedSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CustomAnimatedSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        width: 52,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: value ? AppColors.primary : AppColors.greyLight,
          boxShadow: value
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            TweenAnimationBuilder<double>(
              key: ValueKey<bool>(value),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              tween: Tween<double>(
                begin: value ? 3.5 : 23.5,
                end: value ? 23.5 : 3.5,
              ),
              builder: (context, leftValue, child) {
                return Positioned(
                  left: leftValue,
                  top: 3.5,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomDatePicker extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _CustomDatePicker({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<_CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<_CustomDatePicker> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  String _getMonthYearText(DateTime date) {
    final months = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];
    return '${months[date.month - 1]}, ${date.year}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);

    if (selected == today) {
      return 'Hôm nay';
    } else if (selected == today.add(const Duration(days: 1))) {
      return 'Ngày mai';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Date Display Button
        InkWell(
          onTap: () {
            // Scroll to calendar if needed
          },
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadiusMedium,
              ),
              border: Border.all(
                color: AppColors.primaryLight,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
                Text(
                  _formatDate(_selectedDate),
                  style: R.styles.body(
                    size: 16,
                    weight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        // Calendar
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.greyLight.withOpacity(0.3),
            borderRadius: BorderRadius.circular(
              AppDimensions.borderRadiusLarge,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Month navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.chevron_left, color: AppColors.black),
                    onPressed: () {
                      setState(() {
                        _currentMonth = DateTime(
                          _currentMonth.year,
                          _currentMonth.month - 1,
                        );
                      });
                    },
                  ),
                  Text(
                    _getMonthYearText(_currentMonth),
                    style: R.styles.body(
                      size: 16,
                      weight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.chevron_right, color: AppColors.black),
                    onPressed: () {
                      setState(() {
                        _currentMonth = DateTime(
                          _currentMonth.year,
                          _currentMonth.month + 1,
                        );
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              // Days of week
              Row(
                children: ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7']
                    .map((day) => Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: R.styles.body(
                                size: 12,
                                weight: FontWeight.w600,
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              // Calendar grid - Use Wrap or reduce spacing
              ...List.generate(
                (daysInMonth + firstWeekday + 6) ~/ 7,
                (weekIndex) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (dayIndex) {
                        final dayNumber =
                            weekIndex * 7 + dayIndex - firstWeekday + 1;
                        final isCurrentMonth =
                            dayNumber > 0 && dayNumber <= daysInMonth;
                        final date = isCurrentMonth
                            ? DateTime(
                                _currentMonth.year,
                                _currentMonth.month,
                                dayNumber,
                              )
                            : null;
                        final isToday = date != null &&
                            date.year == DateTime.now().year &&
                            date.month == DateTime.now().month &&
                            date.day == DateTime.now().day;
                        final isSelected = date != null &&
                            date.year == _selectedDate.year &&
                            date.month == _selectedDate.month &&
                            date.day == _selectedDate.day;
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final dateOnly = date != null
                            ? DateTime(date.year, date.month, date.day)
                            : null;
                        final isPast =
                            dateOnly != null && dateOnly.isBefore(today);

                        return Expanded(
                          child: GestureDetector(
                            onTap: isCurrentMonth && !isPast
                                ? () {
                                    setState(() {
                                      _selectedDate = date!;
                                    });
                                    widget.onDateSelected(_selectedDate);
                                  }
                                : null,
                            child: Container(
                              height: 36,
                              margin: const EdgeInsets.all(1.5),
                              decoration: BoxDecoration(
                                color: isToday
                                    ? AppColors.primary
                                    : isSelected
                                        ? AppColors.primaryLight
                                            .withOpacity(0.3)
                                        : Colors.transparent,
                                shape: BoxShape.circle,
                                border: isSelected && !isToday
                                    ? Border.all(
                                        color: AppColors.primary,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  isCurrentMonth ? dayNumber.toString() : '',
                                  style: R.styles.body(
                                    size: 13,
                                    weight: isSelected || isToday
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isPast
                                        ? AppColors.grey.withOpacity(0.6)
                                        : isToday
                                            ? AppColors.white
                                            : isSelected
                                                ? AppColors.primary
                                                : AppColors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
