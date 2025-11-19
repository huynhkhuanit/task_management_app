import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../models/task_model.dart';
import '../utils/navigation_helper.dart';
import '../services/task_service.dart';
import '../services/category_service.dart';
import 'edit_task_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _taskService = TaskService();
  final _categoryService = CategoryService();

  late Task _task;
  String? _categoryName;
  bool _isLoading = true;
  final List<SubTask> _subTasks = [];
  final List<Attachment> _attachments = [];

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _loadTaskDetail();
  }

  Future<void> _loadTaskDetail() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Reload task from database to get latest data
      final updatedTask = await _taskService.getTaskById(_task.id);

      // Load category name if categoryId exists
      String? categoryName;
      if (updatedTask.categoryId != null) {
        try {
          final category =
              await _categoryService.getCategoryById(updatedTask.categoryId!);
          categoryName = category.name;
        } catch (e) {
          // Category not found or error, continue without category name
        }
      }

      // TODO: Load subtasks from database
      // TODO: Load attachments from database

      if (mounted) {
        setState(() {
          _task = updatedTask;
          _categoryName = categoryName;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải chi tiết công việc: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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

  String _formatDate(DateTime date) {
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F9FC),
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Chi tiết công việc',
            style: R.styles.heading2(
              color: AppColors.black,
              weight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          leadingWidth: 56,
          toolbarHeight: 56,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FC),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Chi tiết công việc',
          style: R.styles.heading2(
            color: AppColors.black,
            weight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        leadingWidth: 56,
        toolbarHeight: 56,
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
                      _task.title,
                      style: R.styles.heading1(
                        color: AppColors.black,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),

                    // Task Description
                    if (_task.description != null &&
                        _task.description!.isNotEmpty)
                      Text(
                        _task.description!,
                        style: R.styles
                            .body(
                              size: 16,
                              color: AppColors.greyDark,
                            )
                            .copyWith(height: 1.5),
                      )
                    else
                      Text(
                        'Không có mô tả',
                        style: R.styles
                            .body(
                              size: 16,
                              color: AppColors.grey,
                            )
                            .copyWith(height: 1.5),
                      ),
                    const SizedBox(height: AppDimensions.paddingLarge),

                    // Task Metadata Card
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
                          // Deadline
                          if (_task.dueDate != null)
                            _buildMetadataItem(
                              icon: Icons.calendar_today_outlined,
                              label: 'Hạn chót',
                              value: _formatDate(_task.dueDate!),
                              valueColor: AppColors.black,
                            )
                          else
                            _buildMetadataItem(
                              icon: Icons.calendar_today_outlined,
                              label: 'Hạn chót',
                              value: 'Chưa đặt',
                              valueColor: AppColors.grey,
                            ),
                          Divider(height: 1, color: AppColors.greyLight),

                          // Priority
                          _buildMetadataItem(
                            icon: Icons.priority_high,
                            label: 'Mức độ ưu tiên',
                            value: _getPriorityText(_task.priority),
                            valueColor: _getPriorityColor(_task.priority),
                            isPill: true,
                            priority: _task.priority,
                          ),
                          Divider(height: 1, color: AppColors.greyLight),

                          // Category
                          if (_categoryName != null)
                            _buildMetadataItem(
                              icon: Icons.campaign_outlined,
                              label: 'Danh mục',
                              value: _categoryName!,
                              valueColor: AppColors.primary,
                              isPill: true,
                              category: _categoryName!,
                            )
                          else
                            _buildMetadataItem(
                              icon: Icons.campaign_outlined,
                              label: 'Danh mục',
                              value: 'Chưa có danh mục',
                              valueColor: AppColors.grey,
                              isPill: false,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingLarge),

                    // Sub-tasks Section
                    Text(
                      'Công việc con',
                      style: R.styles.body(
                        size: 18,
                        weight: FontWeight.w700,
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
                      child: _subTasks.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(
                                AppDimensions.paddingLarge,
                              ),
                              child: Center(
                                child: Text(
                                  'Chưa có công việc con',
                                  style: R.styles.body(
                                    size: 14,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              children: _subTasks.map((subTask) {
                                return _buildSubTaskItem(subTask);
                              }).toList(),
                            ),
                    ),
                    const SizedBox(height: AppDimensions.paddingLarge),

                    // Attachments Section
                    Text(
                      'File đính kèm',
                      style: R.styles.body(
                        size: 18,
                        weight: FontWeight.w700,
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
                      padding:
                          const EdgeInsets.all(AppDimensions.paddingMedium),
                      child: _attachments.isEmpty
                          ? Center(
                              child: Text(
                                'Chưa có file đính kèm',
                                style: R.styles.body(
                                  size: 14,
                                  color: AppColors.grey,
                                ),
                              ),
                            )
                          : Row(
                              children: _attachments.map((attachment) {
                                return Expanded(
                                  child: _buildAttachmentItem(attachment),
                                );
                              }).toList(),
                            ),
                    ),
                    const SizedBox(height: AppDimensions.paddingLarge),

                    // Notes Section - Using description as notes for now
                    if (_task.description != null &&
                        _task.description!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ghi chú',
                            style: R.styles.body(
                              size: 18,
                              weight: FontWeight.w700,
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
                            padding: const EdgeInsets.all(
                              AppDimensions.paddingMedium,
                            ),
                            child: Text(
                              _task.description!,
                              style: R.styles
                                  .body(
                                    size: 16,
                                    color: AppColors.greyDark,
                                  )
                                  .copyWith(height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: AppDimensions.paddingLarge),
                  ],
                ),
              ),
            ),

            // Action Buttons
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
                      onPressed: () async {
                        final result =
                            await NavigationHelper.pushSlideTransition(
                          context,
                          EditTaskScreen(
                            task: _task,
                          ),
                        );
                        // If task was updated, refresh the screen
                        if (result == true && mounted) {
                          await _loadTaskDetail();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã cập nhật công việc'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
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
                        'Chỉnh sửa',
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
                        _showDeleteConfirmation();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
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
                        'Xóa',
                        style: R.styles.body(
                          size: 16,
                          weight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        _handleCompleteTask();
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
                        'Hoàn thành',
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

  Widget _buildMetadataItem({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
    bool isPill = false,
    TaskPriority? priority,
    String? category,
  }) {
    return Padding(
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
          if (isPill && priority != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingSmall,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: valueColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                style: R.styles.body(
                  size: 14,
                  weight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            )
          else if (isPill && category != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingSmall,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    value,
                    style: R.styles.body(
                      size: 14,
                      weight: FontWeight.w600,
                      color: valueColor,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              value,
              style: R.styles.body(
                size: 16,
                color: valueColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubTaskItem(SubTask subTask) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.paddingSmall,
        horizontal: AppDimensions.paddingMedium,
      ),
      child: Row(
        children: [
          Checkbox(
            value: subTask.isCompleted,
            onChanged: (value) {
              setState(() {
                subTask.isCompleted = value ?? false;
              });
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
              subTask.title,
              style: R.styles
                  .body(
                    size: 16,
                    color:
                        subTask.isCompleted ? AppColors.grey : AppColors.black,
                  )
                  .copyWith(
                    decoration:
                        subTask.isCompleted ? TextDecoration.lineThrough : null,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem(Attachment attachment) {
    return Container(
      margin: const EdgeInsets.only(
        right: AppDimensions.paddingSmall,
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(
          AppDimensions.borderRadiusMedium,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getFileIconColor(attachment.fileType).withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadiusMedium,
              ),
              border: Border.all(
                color: _getFileIconColor(attachment.fileType),
                width: 2,
              ),
            ),
            child: Icon(
              _getFileIcon(attachment.fileType),
              color: _getFileIconColor(attachment.fileType),
              size: 24,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            attachment.fileName,
            style: R.styles.body(
              size: 12,
              color: AppColors.black,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Xóa công việc',
            style: R.styles.heading3(
              color: AppColors.black,
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa công việc "${_task.title}"? Hành động này không thể hoàn tác.',
            style: R.styles.body(
              color: AppColors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Hủy',
                style: R.styles.body(
                  color: AppColors.grey,
                  weight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performDelete();
              },
              child: Text(
                'Xóa',
                style: R.styles.body(
                  color: AppColors.error,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDelete() async {
    try {
      await _taskService.deleteTask(_task.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa công việc: ${_task.title}'),
            backgroundColor: AppColors.success,
          ),
        );
        // Navigate back after deletion
        Navigator.of(context).pop(true); // Return true to indicate deletion
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xóa công việc: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleCompleteTask() async {
    try {
      await _taskService.completeTask(_task.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã hoàn thành công việc: ${_task.title}'),
            backgroundColor: AppColors.success,
          ),
        );
        // Reload task to get updated status
        await _loadTaskDetail();
        // Navigate back after completion
        Navigator.of(context).pop(true); // Return true to indicate completion
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi hoàn thành công việc: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

// Helper classes
class SubTask {
  String title;
  bool isCompleted;

  SubTask({
    required this.title,
    required this.isCompleted,
  });
}

enum FileType {
  pdf,
  image,
  word,
  excel,
  other,
}

class Attachment {
  final String fileName;
  final FileType fileType;

  Attachment({
    required this.fileName,
    required this.fileType,
  });
}
