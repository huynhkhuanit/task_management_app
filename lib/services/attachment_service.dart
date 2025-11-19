import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attachment_model.dart';
import 'supabase_service.dart';

/// Attachment Service - Xử lý CRUD operations cho task attachments
class AttachmentService {
  /// Lazy getter để tránh khởi tạo client trước khi Supabase được initialize
  SupabaseClient get _client => SupabaseService.client;

  /// Lấy tất cả attachments của một task
  Future<List<Attachment>> getAttachmentsByTaskId(String taskId) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');

      // Verify task belongs to user (RLS will handle security)
      // We'll rely on RLS policies to ensure user can only access their own task attachments

      final response = await _client
          .from('task_attachments')
          .select()
          .eq('task_id', taskId)
          .order('display_order', ascending: true);

      return (response as List)
          .map((json) => Attachment.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy attachments: ${e.toString()}');
    }
  }

  /// Upload attachment và tạo record trong database
  /// 
  /// [taskId] - ID của task
  /// [filePath] - Đường dẫn file local
  /// [fileName] - Tên file
  /// [fileType] - Loại file
  /// [fileSize] - Kích thước file (bytes)
  /// 
  /// Returns: Attachment object
  Future<Attachment> uploadAttachment({
    required String taskId,
    required String filePath,
    required String fileName,
    required FileType fileType,
    required int fileSize,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');

      // Upload file to Supabase Storage
      // Note: This is a simplified version. In production, you would need to:
      // 1. Read the file bytes from filePath
      // 2. Upload using proper file upload method
      // For now, we'll create the database record and assume file upload is handled separately
      final fileNameWithTimestamp = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final storagePath = '$userId/$taskId/$fileNameWithTimestamp';

      // Get public URL (file should be uploaded separately via file picker)
      final fileUrl = _client.storage
          .from('task-attachments')
          .getPublicUrl(storagePath);

      // Create attachment record in database
      final attachmentData = {
        'task_id': taskId,
        'file_name': fileName,
        'file_type': _fileTypeToString(fileType),
        'file_url': fileUrl,
        'file_size': fileSize,
        'display_order': 0,
      };

      final response = await _client
          .from('task_attachments')
          .insert(attachmentData)
          .select()
          .single();

      return Attachment.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi upload attachment: ${e.toString()}');
    }
  }

  /// Xóa attachment
  Future<void> deleteAttachment(String attachmentId) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');

      // Get attachment info to delete from storage
      final attachment = await _client
          .from('task_attachments')
          .select()
          .eq('id', attachmentId)
          .single();

      // Delete from storage (extract path from URL)
      final fileUrl = attachment['file_url'] as String;
      // Extract storage path from URL
      // URL format: https://[project].supabase.co/storage/v1/object/public/task-attachments/[path]
      final pathMatch = RegExp(r'/task-attachments/(.+)$').firstMatch(fileUrl);
      if (pathMatch != null) {
        final storagePath = pathMatch.group(1);
        await _client.storage
            .from('task-attachments')
            .remove([storagePath!]);
      }

      // Delete from database
      await _client
          .from('task_attachments')
          .delete()
          .eq('id', attachmentId);
    } catch (e) {
      throw Exception('Lỗi xóa attachment: ${e.toString()}');
    }
  }

  String _fileTypeToString(FileType type) {
    switch (type) {
      case FileType.pdf:
        return 'pdf';
      case FileType.image:
        return 'image';
      case FileType.word:
        return 'word';
      case FileType.excel:
        return 'excel';
      case FileType.other:
        return 'other';
    }
  }
}

