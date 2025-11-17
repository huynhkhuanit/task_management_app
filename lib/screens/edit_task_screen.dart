import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../models/task_model.dart';
import '../utils/navigation_helper.dart';
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
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _reminderEnabled = true;
  String _selectedCategory = 'Thiết kế';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 15, minute: 0);
  TaskPriority _selectedPriority = TaskPriority.high;

  final List<Attachment> _attachments = [
    Attachment(
      fileName: 'tailieu_thiet_ke.pdf',
      fileType: FileType.pdf,
      fileSize: '1.2 MB',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.task.title,
    );
    _descriptionController = TextEditingController(
      text:
          'Hoàn thiện thiết kế UI/UX cho màn hình thông tin người dùng, bao gồm ảnh đại diện, thông tin cá nhân và các mục cài đặt liên quan.',
    );
    _selectedPriority = widget.task.priority;
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

  String _formatDate(DateTime date) {
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

  String _formatTime(TimeOfDay time) {
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
      initialTime: _selectedTime,
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

  void _handleSave() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tiêu đề công việc'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    // TODO: Implement save logic
    Navigator.of(context).pop(true); // Return true to indicate success
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu công việc'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
                            value: _selectedCategory,
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
                                      if (attachment.fileSize != null)
                                        Text(
                                          attachment.fileSize!,
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
                      onPressed: _handleSave,
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
    required String value,
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
              value,
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

// Attachment class with file size
class Attachment {
  final String fileName;
  final FileType fileType;
  final String? fileSize;

  Attachment({
    required this.fileName,
    required this.fileType,
    this.fileSize,
  });
}

enum FileType {
  pdf,
  image,
  word,
  excel,
  other,
}
