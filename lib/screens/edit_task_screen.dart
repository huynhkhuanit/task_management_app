import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../models/task_model.dart';
import '../models/attachment_model.dart';
import '../utils/navigation_helper.dart';
import '../services/task_service.dart';
import '../services/category_service.dart';
import 'categories_screen.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _taskService = TaskService();
  final _categoryService = CategoryService();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _reminderEnabled = true;
  String? _selectedCategory;
  String? _selectedCategoryId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  TaskPriority _selectedPriority = TaskPriority.medium;
  bool _isLoading = true;
  bool _isSaving = false;

  final List<Attachment> _attachments = [];

  @override
  void initState() {
    super.initState();
    _loadTaskData();
  }

  Future<void> _loadTaskData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load task details from database
      final task = await _taskService.getTaskById(widget.task.id);
      
      // Load category name if exists
      if (task.categoryId != null) {
        try {
          final category = await _categoryService.getCategoryById(task.categoryId!);
          _selectedCategory = category.name;
          _selectedCategoryId = category.id;
        } catch (e) {
          // Category not found
        }
      }

      _titleController = TextEditingController(text: task.title);
      _descriptionController = TextEditingController(text: task.description ?? '');
      _selectedPriority = task.priority;
      _selectedDate = task.dueDate;
      if (task.dueDate != null) {
        _selectedTime = TimeOfDay.fromDateTime(task.dueDate!);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // Use widget.task as fallback
      _titleController = TextEditingController(text: widget.task.title);
      _descriptionController = TextEditingController(text: widget.task.description ?? '');
      _selectedPriority = widget.task.priority;
      _selectedDate = widget.task.dueDate;
      if (widget.task.dueDate != null) {
        _selectedTime = TimeOfDay.fromDateTime(widget.task.dueDate!);
      }
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AppColors.primary;
      case TaskPriority.medium:
        return const Color(0xFFFF9500);
      case TaskPriority.high:
        return const Color(0xFFFF9500);
      case TaskPriority.urgent:
        return const Color(0xFFFF3B30);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chọn ngày';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hôm nay';
    } else if (dateOnly == today.add(const Duration(days: 1))) {
      return 'Ngày mai';
    } else {
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
        'Tháng 12'
      ];
      return '${date.day} ${months[date.month - 1]}, ${date.year}';
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Chọn giờ';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  IconData _getFileIcon(FileType fileType) {
    switch (fileType) {
      case FileType.pdf:
        return Icons.picture_as_pdf;
      case FileType.image:
        return Icons.image;
      case FileType.word:
        return Icons.description;
      case FileType.excel:
        return Icons.table_chart;
      case FileType.other:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileIconColor(FileType fileType) {
    switch (fileType) {
      case FileType.pdf:
        return const Color(0xFFFF3B30);
      case FileType.image:
        return const Color(0xFF4A90E2);
      case FileType.word:
        return const Color(0xFF2B579A);
      case FileType.excel:
        return const Color(0xFF217346);
      case FileType.other:
        return AppColors.grey;
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
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

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
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

  void _showCategoryPicker() async {
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

  void _showPriorityPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.borderRadiusXLarge),
        ),
      ),
      builder: (context) {
        final priorities = [
          TaskPriority.low,
          TaskPriority.medium,
          TaskPriority.high,
          TaskPriority.urgent,
        ];
        return Container(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: priorities.map((priority) {
              return ListTile(
                title: Text(
                  _getPriorityText(priority),
                  style: R.styles.body(
                    size: 16,
                    color: AppColors.black,
                  ),
                ),
                trailing: _selectedPriority == priority
                    ? Icon(Icons.check, color: _getPriorityColor(priority))
                    : null,
                onTap: () {
                  setState(() {
                    _selectedPriority = priority;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _addFile() {
    // TODO: Implement file picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng thêm file sẽ được triển khai')),
    );
  }

  void _deleteFile(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  Future<void> _handleSave() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tiêu đề công việc'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Get category ID from category name
      String? categoryId = _selectedCategoryId;
      if (_selectedCategory != null && _selectedCategory!.isNotEmpty && categoryId == null) {
        try {
          final categories = await _categoryService.getCategories();
          final category = categories.firstWhere(
            (c) => c.name == _selectedCategory,
          );
          categoryId = category.id;
        } catch (e) {
          // Category not found, continue without categoryId
          categoryId = null;
        }
      }

      // Combine date and time for dueDate
      DateTime? dueDate;
      if (_selectedDate != null && _selectedTime != null) {
        dueDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
      }

      // Calculate reminder time (15 minutes before due date if reminder is enabled)
      DateTime? reminderTime;
      if (_reminderEnabled && dueDate != null) {
        reminderTime = dueDate.subtract(const Duration(minutes: 15));
      }

      // Update task in database
      await _taskService.updateTask(
        taskId: widget.task.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        categoryId: categoryId,
        dueDate: dueDate,
        priority: _selectedPriority,
        reminderEnabled: _reminderEnabled,
        reminderTime: reminderTime,
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu công việc'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi lưu công việc: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.black),
            onPressed: _handleCancel,
          ),
          title: Text(
            'Chỉnh sửa công việc',
            style: R.styles.heading2(
              color: AppColors.black,
              weight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.black),
          onPressed: _handleCancel,
        ),
        title: Text(
          'Chỉnh sửa công việc',
          style: R.styles.heading2(
            color: AppColors.black,
            weight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        leadingWidth: 56,
        toolbarHeight: 56,
        automaticallyImplyLeading: false,
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
                    Text(
                      'Tiêu đề công việc',
                      style: R.styles.body(
                        size: 16,
                        weight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    TextField(
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
                        filled: true,
                        fillColor: AppColors.greyLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusMedium,
                          ),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(
                          AppDimensions.paddingMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingLarge),

                    // Description
                    Text(
                      'Mô tả',
                      style: R.styles.body(
                        size: 16,
                        weight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      style: R.styles.body(
                        size: 16,
                        color: AppColors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Nhập mô tả công việc',
                        hintStyle: R.styles.body(
                          size: 16,
                          color: AppColors.grey,
                        ),
                        filled: true,
                        fillColor: AppColors.greyLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusMedium,
                          ),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(
                          AppDimensions.paddingMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingLarge),

                    // Task Attributes Card
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
                          _buildAttributeItem(
                            icon: Icons.folder_outlined,
                            iconColor: AppColors.primary,
                            label: 'Danh mục',
                            value: _selectedCategory ?? 'Chọn danh mục',
                            valueColor: AppColors.primary,
                            onTap: _showCategoryPicker,
                          ),
                          Divider(height: 1, color: AppColors.greyLight),
                          // Date
                          _buildAttributeItem(
                            icon: Icons.calendar_today_outlined,
                            iconColor: AppColors.primary,
                            label: 'Ngày',
                            value: _formatDate(_selectedDate),
                            valueColor: AppColors.primary,
                            onTap: _selectDate,
                          ),
                          Divider(height: 1, color: AppColors.greyLight),
                          // Time
                          _buildAttributeItem(
                            icon: Icons.access_time_outlined,
                            iconColor: AppColors.primary,
                            label: 'Giờ',
                            value: _formatTime(_selectedTime),
                            valueColor: AppColors.primary,
                            onTap: _selectTime,
                          ),
                          Divider(height: 1, color: AppColors.greyLight),
                          // Priority
                          _buildAttributeItem(
                            icon: Icons.flag_outlined,
                            iconColor: _getPriorityColor(_selectedPriority),
                            label: 'Độ ưu tiên',
                            value: _getPriorityText(_selectedPriority),
                            valueColor: _getPriorityColor(_selectedPriority),
                            onTap: _showPriorityPicker,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingLarge),

                    // Reminder Card
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingMedium,
                          horizontal: AppDimensions.paddingMedium,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.notifications_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: AppDimensions.paddingMedium),
                            Expanded(
                              child: Text(
                                'Nhắc nhở',
                                style: R.styles.body(
                                  size: 16,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                            _CustomAnimatedSwitch(
                              value: _reminderEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _reminderEnabled = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingLarge),

                    // File Attachments
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'File đính kèm',
                          style: R.styles.body(
                            size: 16,
                            weight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        TextButton(
                          onPressed: _addFile,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Thêm file',
                            style: R.styles.body(
                              size: 16,
                              weight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    if (_attachments.isNotEmpty)
                      ..._attachments.asMap().entries.map((entry) {
                        final index = entry.key;
                        final attachment = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall,
                          ),
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
                          child: Padding(
                            padding: const EdgeInsets.all(
                              AppDimensions.paddingMedium,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color:
                                        _getFileIconColor(attachment.fileType)
                                            .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.borderRadiusMedium,
                                    ),
                                  ),
                                  child: Icon(
                                    _getFileIcon(attachment.fileType),
                                    color:
                                        _getFileIconColor(attachment.fileType),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(
                                    width: AppDimensions.paddingMedium),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        attachment.fileName,
                                        style: R.styles.body(
                                          size: 16,
                                          color: AppColors.black,
                                        ),
                                      ),
                                      Text(
                                        attachment.fileSize,
                                        style: R.styles.body(
                                          size: 14,
                                          color: AppColors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () => _deleteFile(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),

            // Footer Buttons
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
                      onPressed: _handleCancel,
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
                      onPressed: _isSaving ? null : _handleSave,
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
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                              ),
                            )
                          : Text(
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

  Widget _CustomAnimatedSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
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

  Widget _buildAttributeItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String? value,
    required Color valueColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingMedium,
          horizontal: AppDimensions.paddingMedium,
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
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
            Text(
              value ?? '',
              style: R.styles.body(
                size: 16,
                weight: FontWeight.w600,
                color: valueColor,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            Icon(
              Icons.chevron_right,
              color: AppColors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// Attachment and FileType are imported from attachment_model.dart
