enum FileType {
  pdf,
  image,
  word,
  excel,
  other,
}

class Attachment {
  final String id;
  final String fileName;
  final FileType fileType;
  final String fileSize;
  final String fileUrl;
  final int? displayOrder;

  Attachment({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.fileUrl,
    this.displayOrder,
  });

  static FileType _stringToFileType(String type) {
    switch (type) {
      case 'pdf':
        return FileType.pdf;
      case 'image':
        return FileType.image;
      case 'word':
        return FileType.word;
      case 'excel':
        return FileType.excel;
      default:
        return FileType.other;
    }
  }

  static String _fileTypeToString(FileType type) {
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

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'] as String,
      fileName: json['file_name'] as String,
      fileType: _stringToFileType(json['file_type'] as String),
      fileSize: _formatFileSize(json['file_size'] as int? ?? 0),
      fileUrl: json['file_url'] as String,
      displayOrder: json['display_order'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'file_type': _fileTypeToString(fileType),
      'file_size': _parseFileSize(fileSize),
      'file_url': fileUrl,
      'display_order': displayOrder,
    };
  }

  static String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  static int _parseFileSize(String size) {
    // Parse "1.2 MB" to bytes
    final parts = size.split(' ');
    if (parts.length != 2) return 0;
    
    final value = double.tryParse(parts[0]) ?? 0;
    final unit = parts[1].toUpperCase();
    
    switch (unit) {
      case 'B':
        return value.toInt();
      case 'KB':
        return (value * 1024).toInt();
      case 'MB':
        return (value * 1024 * 1024).toInt();
      case 'GB':
        return (value * 1024 * 1024 * 1024).toInt();
      default:
        return 0;
    }
  }
}

