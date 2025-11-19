import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';
import 'supabase_service.dart';

/// Task Service - Xử lý CRUD operations cho tasks
class TaskService {
  /// Lazy getter để tránh khởi tạo client trước khi Supabase được initialize
  SupabaseClient get _client => SupabaseService.client;

  /// Lấy tất cả tasks của user hiện tại
  ///
  /// [status] - Lọc theo status (optional)
  /// [priority] - Lọc theo priority (optional)
  /// [categoryId] - Lọc theo category (optional)
  ///
  /// Returns: List of tasks
  Future<List<Task>> getTasks({
    TaskStatus? status,
    TaskPriority? priority,
    String? categoryId,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');

      var query = _client.from('tasks').select().eq('user_id', userId);

      if (status != null) {
        query = query.eq('status', _statusToString(status));
      }

      if (priority != null) {
        query = query.eq('priority', _priorityToString(priority));
      }

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      final response = await query.order('created_at', ascending: false);
      return (response as List).map((json) => _taskFromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách tasks: ${e.toString()}');
    }
  }

  /// Lấy task theo ID
  Future<Task> getTaskById(String taskId) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');

      final response = await _client
          .from('tasks')
          .select()
          .eq('id', taskId)
          .eq('user_id', userId)
          .single();

      return _taskFromJson(response);
    } catch (e) {
      throw Exception('Lỗi lấy task: ${e.toString()}');
    }
  }

  /// Tạo task mới
  Future<Task> createTask({
    required String title,
    String? description,
    String? project,
    String? categoryId,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
    bool reminderEnabled = true,
    DateTime? reminderTime,
    List<String>? tags,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');

      final taskData = {
        'user_id': userId,
        'title': title,
        'description': description,
        'project': project,
        'category_id': categoryId,
        'due_date': dueDate?.toIso8601String(),
        'priority': _priorityToString(priority),
        'status': 'pending',
        'reminder_enabled': reminderEnabled,
        'reminder_time': reminderTime?.toIso8601String(),
      };

      final response =
          await _client.from('tasks').insert(taskData).select().single();

      final task = _taskFromJson(response);

      // Thêm tags nếu có
      if (tags != null && tags.isNotEmpty) {
        await _addTagsToTask(task.id, tags);
      }

      return task;
    } catch (e) {
      throw Exception('Lỗi tạo task: ${e.toString()}');
    }
  }

  /// Cập nhật task
  Future<Task> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? project,
    String? categoryId,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    bool? reminderEnabled,
    DateTime? reminderTime,
    List<String>? tags,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');

      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (project != null) updateData['project'] = project;
      if (categoryId != null) updateData['category_id'] = categoryId;
      if (dueDate != null) updateData['due_date'] = dueDate.toIso8601String();
      if (priority != null)
        updateData['priority'] = _priorityToString(priority);
      if (status != null) updateData['status'] = _statusToString(status);
      if (reminderEnabled != null)
        updateData['reminder_enabled'] = reminderEnabled;
      if (reminderTime != null)
        updateData['reminder_time'] = reminderTime.toIso8601String();

      final response = await _client
          .from('tasks')
          .update(updateData)
          .eq('id', taskId)
          .eq('user_id', userId)
          .select()
          .single();

      final task = _taskFromJson(response);

      // Cập nhật tags nếu có
      if (tags != null) {
        await _updateTaskTags(taskId, tags);
      }

      return task;
    } catch (e) {
      throw Exception('Lỗi cập nhật task: ${e.toString()}');
    }
  }

  /// Xóa task
  Future<void> deleteTask(String taskId) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');

      await _client
          .from('tasks')
          .delete()
          .eq('id', taskId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Lỗi xóa task: ${e.toString()}');
    }
  }

  /// Đánh dấu task là hoàn thành
  Future<Task> completeTask(String taskId) async {
    return updateTask(
      taskId: taskId,
      status: TaskStatus.completed,
    );
  }

  /// Lấy tasks theo ngày
  Future<List<Task>> getTasksByDate(DateTime date) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _client
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .gte('due_date', startOfDay.toIso8601String())
          .lt('due_date', endOfDay.toIso8601String())
          .order('due_date', ascending: true);

      return (response as List).map((json) => _taskFromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy tasks theo ngày: ${e.toString()}');
    }
  }

  /// Lấy tasks quá hạn
  Future<List<Task>> getOverdueTasks() async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');

      final response = await _client
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .lt('due_date', DateTime.now().toIso8601String())
          .neq('status', 'completed')
          .order('due_date', ascending: true);

      return (response as List).map((json) => _taskFromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy tasks quá hạn: ${e.toString()}');
    }
  }

  // Helper methods
  Task _taskFromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      project: json['project'] as String? ?? '',
      time: DateTime.parse(json['created_at'] as String),
      status: _stringToStatus(json['status'] as String),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      priority: _stringToPriority(json['priority'] as String),
      tags: [], // Tags sẽ được load riêng nếu cần
      categoryId: json['category_id'] as String?,
    );
  }

  String _statusToString(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'pending';
      case TaskStatus.completed:
        return 'completed';
      case TaskStatus.overdue:
        return 'overdue';
    }
  }

  TaskStatus _stringToStatus(String status) {
    switch (status) {
      case 'pending':
        return TaskStatus.pending;
      case 'completed':
        return TaskStatus.completed;
      case 'overdue':
        return TaskStatus.overdue;
      default:
        return TaskStatus.pending;
    }
  }

  String _priorityToString(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'low';
      case TaskPriority.medium:
        return 'medium';
      case TaskPriority.high:
        return 'high';
      case TaskPriority.urgent:
        return 'urgent';
    }
  }

  TaskPriority _stringToPriority(String priority) {
    switch (priority) {
      case 'low':
        return TaskPriority.low;
      case 'medium':
        return TaskPriority.medium;
      case 'high':
        return TaskPriority.high;
      case 'urgent':
        return TaskPriority.urgent;
      default:
        return TaskPriority.medium;
    }
  }

  Future<void> _addTagsToTask(String taskId, List<String> tags) async {
    final tagData = tags
        .map((tag) => {
              'task_id': taskId,
              'tag_name': tag,
            })
        .toList();

    await _client.from('task_tags').insert(tagData);
  }

  Future<void> _updateTaskTags(String taskId, List<String> tags) async {
    // Xóa tags cũ
    await _client.from('task_tags').delete().eq('task_id', taskId);

    // Thêm tags mới
    if (tags.isNotEmpty) {
      await _addTagsToTask(taskId, tags);
    }
  }

  /// Tạo subtasks cho một task
  Future<void> createSubtasks(String taskId, List<String> subtaskTitles) async {
    try {
      if (subtaskTitles.isEmpty) return;

      final subtaskData = subtaskTitles.asMap().entries.map((entry) {
        return {
          'task_id': taskId,
          'title': entry.value,
          'is_completed': false,
          'display_order': entry.key,
        };
      }).toList();

      await _client.from('subtasks').insert(subtaskData);
    } catch (e) {
      throw Exception('Lỗi tạo subtasks: ${e.toString()}');
    }
  }

  /// Lấy subtasks của một task
  Future<List<Map<String, dynamic>>> getSubtasks(String taskId) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');

      // Verify task belongs to user (RLS will handle security)
      await getTaskById(taskId);

      final response = await _client
          .from('subtasks')
          .select()
          .eq('task_id', taskId)
          .order('display_order', ascending: true);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Lỗi lấy subtasks: ${e.toString()}');
    }
  }

  /// Cập nhật trạng thái subtask
  Future<void> updateSubtaskStatus(String subtaskId, bool isCompleted) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');

      await _client
          .from('subtasks')
          .update({'is_completed': isCompleted})
          .eq('id', subtaskId);
    } catch (e) {
      throw Exception('Lỗi cập nhật subtask: ${e.toString()}');
    }
  }
}
