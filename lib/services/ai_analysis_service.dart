import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// AI Analysis Service - Phân tích dữ liệu thống kê bằng AI
/// Sử dụng OpenAI API hoặc tương tự để phân tích và đưa ra insights
class AIAnalysisService {
  // API endpoint - có thể là OpenAI hoặc custom AI service
  String? get _apiUrl => dotenv.env['AI_API_URL'] ?? 'https://api.openai.com/v1/chat/completions';
  String? get _apiKey => dotenv.env['AI_API_KEY'];
  
  /// Phân tích dữ liệu thống kê và trả về insights từ AI
  /// 
  /// [statistics] - Map chứa các thống kê:
  ///   - completionRate: Tỷ lệ hoàn thành (%)
  ///   - totalTasks: Tổng số công việc
  ///   - completedTasks: Số công việc đã hoàn thành
  ///   - overdueTasks: Số công việc quá hạn
  ///   - performanceScore: Điểm hiệu suất (0-10)
  ///   - categoryDistribution: Map<categoryName, percentage>
  ///   - period: Chu kỳ thống kê (Tuần/Tháng/Năm)
  /// 
  /// Returns: Phân tích từ AI (giới hạn 300 từ)
  Future<String> analyzeStatistics(Map<String, dynamic> statistics) async {
    try {
      // Nếu không có API key, trả về phân tích mẫu
      if (_apiKey == null || _apiKey!.isEmpty) {
        return _generateFallbackAnalysis(statistics);
      }

      // Tạo prompt chuyên nghiệp và khoa học
      final prompt = _buildProfessionalPrompt(statistics);
      
      // Gọi AI API
      final response = await http.post(
        Uri.parse(_apiUrl!),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo', // hoặc 'gpt-4' nếu có
          'messages': [
            {
              'role': 'system',
              'content': _getSystemPrompt(),
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'max_tokens': 300, // Giới hạn độ dài câu trả lời
          'temperature': 0.7, // Cân bằng giữa sáng tạo và chính xác
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        return _limitResponseLength(content, maxWords: 300);
      } else {
        debugPrint('AI API Error: ${response.statusCode} - ${response.body}');
        return _generateFallbackAnalysis(statistics);
      }
    } catch (e) {
      debugPrint('Lỗi gọi AI API: ${e.toString()}');
      return _generateFallbackAnalysis(statistics);
    }
  }

  /// Tạo system prompt để dạy AI cách trả lời khoa học và chuyên nghiệp
  String _getSystemPrompt() {
    return '''Bạn là một chuyên gia phân tích dữ liệu và quản lý công việc chuyên nghiệp. 
Nhiệm vụ của bạn là phân tích dữ liệu thống kê và đưa ra những insights có giá trị.

QUY TẮC TRẢ LỜI:
1. Sử dụng ngôn ngữ khoa học, chuyên nghiệp nhưng dễ hiểu
2. Đưa ra phân tích dựa trên dữ liệu thực tế, không suy đoán
3. Sử dụng số liệu cụ thể từ dữ liệu được cung cấp
4. Đưa ra nhận xét khách quan và xây dựng
5. Giới hạn trong 300 từ
6. Cấu trúc: Phân tích → Nhận xét → Gợi ý (nếu có)
7. Sử dụng thuật ngữ chuyên ngành phù hợp
8. Tránh lặp lại thông tin đã có trong dữ liệu

TONE: Chuyên nghiệp, khách quan, tích cực, mang tính xây dựng''';
  }

  /// Tạo prompt chuyên nghiệp từ dữ liệu thống kê
  String _buildProfessionalPrompt(Map<String, dynamic> stats) {
    final period = stats['period'] ?? 'Tháng';
    final completionRate = stats['completionRate'] ?? 0.0;
    final totalTasks = stats['totalTasks'] ?? 0;
    final completedTasks = stats['completedTasks'] ?? 0;
    final overdueTasks = stats['overdueTasks'] ?? 0;
    final performanceScore = stats['performanceScore'] ?? 0.0;
    final categoryDistribution = stats['categoryDistribution'] as Map<String, dynamic>? ?? {};

    return '''Phân tích dữ liệu thống kê công việc trong $period:

THỐNG KÊ:
- Tổng số công việc: $totalTasks
- Đã hoàn thành: $completedTasks
- Quá hạn: $overdueTasks
- Tỷ lệ hoàn thành: ${completionRate.toStringAsFixed(1)}%
- Điểm hiệu suất: ${performanceScore.toStringAsFixed(1)}/10

PHÂN LOẠI:
${categoryDistribution.entries.map((e) => '- ${e.key}: ${e.value}%').join('\n')}

Hãy phân tích các chỉ số này một cách khoa học và đưa ra insights có giá trị về:
1. Hiệu quả làm việc
2. Xu hướng và patterns
3. Điểm mạnh và điểm cần cải thiện
4. Gợi ý hành động cụ thể (nếu có)

Giới hạn: 300 từ, ngôn ngữ chuyên nghiệp, dựa trên dữ liệu thực tế.''';
  }

  /// Giới hạn độ dài câu trả lời
  String _limitResponseLength(String text, {int maxWords = 300}) {
    final words = text.split(' ');
    if (words.length <= maxWords) {
      return text;
    }
    
    final limitedWords = words.take(maxWords).toList();
    return '${limitedWords.join(' ')}...';
  }

  /// Tạo phân tích fallback khi không có API
  String _generateFallbackAnalysis(Map<String, dynamic> stats) {
    final completionRate = stats['completionRate'] ?? 0.0;
    final overdueTasks = stats['overdueTasks'] ?? 0;
    final performanceScore = stats['performanceScore'] ?? 0.0;
    final period = stats['period'] ?? 'Tháng';

    String analysis = 'Phân tích dữ liệu thống kê trong $period:\n\n';
    
    // Phân tích completion rate
    if (completionRate >= 80) {
      analysis += 'Tỷ lệ hoàn thành ${completionRate.toStringAsFixed(1)}% cho thấy hiệu quả làm việc tốt. ';
    } else if (completionRate >= 50) {
      analysis += 'Tỷ lệ hoàn thành ${completionRate.toStringAsFixed(1)}% ở mức trung bình, cần cải thiện. ';
    } else {
      analysis += 'Tỷ lệ hoàn thành ${completionRate.toStringAsFixed(1)}% còn thấp, cần tập trung vào việc hoàn thành công việc. ';
    }

    // Phân tích overdue tasks
    if (overdueTasks > 0) {
      analysis += 'Có $overdueTasks công việc quá hạn cần được xử lý ngay. ';
    } else {
      analysis += 'Không có công việc quá hạn, quản lý thời gian tốt. ';
    }

    // Phân tích performance score
    if (performanceScore >= 8) {
      analysis += 'Điểm hiệu suất ${performanceScore.toStringAsFixed(1)}/10 cho thấy hiệu quả làm việc xuất sắc.';
    } else if (performanceScore >= 6) {
      analysis += 'Điểm hiệu suất ${performanceScore.toStringAsFixed(1)}/10 ở mức khá, có thể cải thiện thêm.';
    } else {
      analysis += 'Điểm hiệu suất ${performanceScore.toStringAsFixed(1)}/10 cần được cải thiện thông qua việc tăng tỷ lệ hoàn thành và giảm số công việc quá hạn.';
    }

    return analysis;
  }
}

