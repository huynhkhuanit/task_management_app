import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../models/task_model.dart';
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
  // Sample data based on the design
  final String _description =
      'Review the draft, gather final data from the analytics team, and prepare the presentation slides for the board meeting.';
  final DateTime _deadline = DateTime(2024, 10, 28);
  final String _category = 'Marketing';
  final String _notes =
      'Remember to double-check the Q2 comparison figures. Sarah from the sales team has the most updated numbers. Contact her before finalizing.';

  final List<SubTask> _subTasks = [
    SubTask(title: 'Gather final data from analytics', isCompleted: true),
    SubTask(title: 'Prepare presentation slides', isCompleted: false),
    SubTask(title: 'Review draft with team lead', isCompleted: false),
  ];

  final List<Attachment> _attachments = [
    Attachment(
      fileName: 'Report_Draft_v3.pdf',
      fileType: FileType.pdf,
    ),
    Attachment(
      fileName: 'Infographic_Data.png',
      fileType: FileType.image,
    ),
  ];

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
                      widget.task.title,
                      style: R.styles.heading1(
                        color: AppColors.black,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),

                    // Task Description
                    Text(
                      _description,
                      style: R.styles.body(
                        size: 16,
                        color: AppColors.greyDark,
                      ).copyWith(height: 1.5),
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
                          _buildMetadataItem(
                            icon: Icons.calendar_today_outlined,
                            label: 'Hạn chót',
                            value: _formatDate(_deadline),
                            valueColor: AppColors.black,
                          ),
                          Divider(height: 1, color: AppColors.greyLight),

                          // Priority
                          _buildMetadataItem(
                            icon: Icons.priority_high,
                            label: 'Mức độ ưu tiên',
                            value: _getPriorityText(widget.task.priority),
                            valueColor: _getPriorityColor(widget.task.priority),
                            isPill: true,
                            priority: widget.task.priority,
                          ),
                          Divider(height: 1, color: AppColors.greyLight),

                          // Category
                          _buildMetadataItem(
                            icon: Icons.campaign_outlined,
                            label: 'Danh mục',
                            value: _category,
                            valueColor: AppColors.primary,
                            isPill: true,
                            category: _category,
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
                      child: Column(
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
                      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                      child: Row(
                        children: _attachments.map((attachment) {
                          return Expanded(
                            child: _buildAttachmentItem(attachment),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingLarge),

                    // Notes Section
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
                      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                      child: Text(
                        _notes,
                        style: R.styles.body(
                          size: 16,
                          color: AppColors.greyDark,
                        ).copyWith(height: 1.5),
                      ),
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
                      onPressed: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                EditTaskScreen(
                              task: widget.task,
                            ),
                            transitionsBuilder:
                                (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 200),
                          ),
                        );
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
                        // TODO: Handle delete
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
                        // TODO: Handle complete
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
              style: R.styles.body(
                size: 16,
                color: subTask.isCompleted
                    ? AppColors.grey
                    : AppColors.black,
              ).copyWith(
                decoration: subTask.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
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
              color: _getFileIconColor(attachment.fileType)
                  .withOpacity(0.1),
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

