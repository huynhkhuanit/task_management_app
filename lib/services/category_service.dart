import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';
import 'supabase_service.dart';

/// Category Service - Xử lý CRUD operations cho categories
class CategoryService {
  /// Lazy getter để tránh khởi tạo client trước khi Supabase được initialize
  SupabaseClient get _client => SupabaseService.client;
  
  /// Lấy tất cả categories của user hiện tại
  Future<List<Category>> getCategories() async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');
      
      final response = await _client
          .from('categories')
          .select()
          .eq('user_id', userId)
          .order('display_order', ascending: true);
      
      final categories = (response as List)
          .map((json) => _categoryFromJson(json))
          .toList();
      
      // Load task count for each category
      final categoriesWithCount = <Category>[];
      for (var category in categories) {
        try {
          final taskCountResponse = await _client
              .from('tasks')
              .select('id')
              .eq('user_id', userId)
              .eq('category_id', category.id);
          
          final taskCount = (taskCountResponse as List).length;
          categoriesWithCount.add(category.copyWith(taskCount: taskCount));
        } catch (e) {
          // If error, keep taskCount as 0
          categoriesWithCount.add(category);
        }
      }
      
      return categoriesWithCount;
    } catch (e) {
      throw Exception('Lỗi lấy danh sách categories: ${e.toString()}');
    }
  }
  
  /// Lấy category theo ID
  Future<Category> getCategoryById(String categoryId) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');
      
      final response = await _client
          .from('categories')
          .select()
          .eq('id', categoryId)
          .eq('user_id', userId)
          .single();
      
      return _categoryFromJson(response);
    } catch (e) {
      throw Exception('Lỗi lấy category: ${e.toString()}');
    }
  }
  
  /// Tạo category mới
  Future<Category> createCategory({
    required String name,
    required String iconName,
    required String colorHex,
    int? displayOrder,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');
      
      // Lấy order cao nhất nếu không chỉ định
      int order = displayOrder ?? 0;
      if (displayOrder == null) {
        final categories = await getCategories();
        if (categories.isNotEmpty) {
          order = categories.map((c) => c.order).reduce((a, b) => a > b ? a : b) + 1;
        }
      }
      
      final categoryData = {
        'user_id': userId,
        'name': name,
        'icon_name': iconName,
        'color_hex': colorHex,
        'display_order': order,
      };
      
      final response = await _client
          .from('categories')
          .insert(categoryData)
          .select()
          .single();
      
      return _categoryFromJson(response);
    } catch (e) {
      throw Exception('Lỗi tạo category: ${e.toString()}');
    }
  }
  
  /// Cập nhật category
  Future<Category> updateCategory({
    required String categoryId,
    String? name,
    String? iconName,
    String? colorHex,
    int? displayOrder,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');
      
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (iconName != null) updateData['icon_name'] = iconName;
      if (colorHex != null) updateData['color_hex'] = colorHex;
      if (displayOrder != null) updateData['display_order'] = displayOrder;
      
      final response = await _client
          .from('categories')
          .update(updateData)
          .eq('id', categoryId)
          .eq('user_id', userId)
          .select()
          .single();
      
      return _categoryFromJson(response);
    } catch (e) {
      throw Exception('Lỗi cập nhật category: ${e.toString()}');
    }
  }
  
  /// Xóa category
  Future<void> deleteCategory(String categoryId) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');
      
      await _client
          .from('categories')
          .delete()
          .eq('id', categoryId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Lỗi xóa category: ${e.toString()}');
    }
  }
  
  /// Cập nhật thứ tự categories
  Future<void> reorderCategories(List<String> categoryIds) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Chưa đăng nhập');
      
      for (int i = 0; i < categoryIds.length; i++) {
        await _client
            .from('categories')
            .update({'display_order': i})
            .eq('id', categoryIds[i])
            .eq('user_id', userId);
      }
    } catch (e) {
      throw Exception('Lỗi sắp xếp lại categories: ${e.toString()}');
    }
  }
  
  // Helper methods
  Category _categoryFromJson(Map<String, dynamic> json) {
    // Parse icon từ icon_name (cần mapping với IconData)
    // Vì IconData không thể serialize, ta lưu tên icon và map lại
    IconData icon = Icons.work_outline; // Default
    try {
      // Có thể tạo một map để convert icon name sang IconData
      icon = _iconNameToIconData(json['icon_name'] as String);
    } catch (e) {
      // Fallback to default
    }
    
    // Parse color từ hex string
    Color color = const Color(0xFF4FD1C7); // Default
    try {
      final hexString = json['color_hex'] as String;
      color = Color(int.parse(hexString.replaceFirst('#', '0xFF')));
    } catch (e) {
      // Fallback to default
    }
    
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: icon,
      color: color,
      taskCount: 0, // Sẽ được tính riêng nếu cần
      order: json['display_order'] as int? ?? 0,
    );
  }
  
  // Map icon name to IconData
  // Có thể mở rộng thêm các icons khác
  IconData _iconNameToIconData(String iconName) {
    final iconMap = {
      'work_outline': Icons.work_outline,
      'person_outline': Icons.person_outline,
      'school_outlined': Icons.school_outlined,
      'shopping_cart_outlined': Icons.shopping_cart_outlined,
      'star_outline': Icons.star_outline,
      'bookmark_outline': Icons.bookmark_outline,
      'flight_outlined': Icons.flight_outlined,
      'favorite_outline': Icons.favorite_outline,
      'home_outlined': Icons.home_outlined,
      'lightbulb_outline': Icons.lightbulb_outline,
    };
    
    return iconMap[iconName] ?? Icons.work_outline;
  }
  
  // Convert IconData to icon name
  String _iconDataToIconName(IconData icon) {
    // Reverse mapping - cần implement dựa trên icon codePoint
    // Tạm thời return default
    return 'work_outline';
  }
}

