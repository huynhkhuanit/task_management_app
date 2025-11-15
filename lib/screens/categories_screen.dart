import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../models/category_model.dart';
import '../widgets/bottom_navigation_bar.dart';

class CategoriesScreen extends StatefulWidget {
  final String? selectedCategoryName;
  final Function(String)? onCategorySelected;

  const CategoriesScreen({
    Key? key,
    this.selectedCategoryName,
    this.onCategorySelected,
  }) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late List<Category> _categories;

  @override
  void initState() {
    super.initState();
    _categories = [
      Category(
        id: '1',
        name: 'Công việc',
        icon: Icons.work_outline,
        color: AppColors.primary,
        taskCount: 10,
        order: 0,
      ),
      Category(
        id: '2',
        name: 'Học tập',
        icon: Icons.school_outlined,
        color: const Color(0xFF10B981),
        taskCount: 8,
        order: 1,
      ),
      Category(
        id: '3',
        name: 'Cá nhân',
        icon: Icons.person_outline,
        color: const Color(0xFF8B5CF6),
        taskCount: 5,
        order: 2,
      ),
      Category(
        id: '4',
        name: 'Mua sắm',
        icon: Icons.shopping_cart_outlined,
        color: const Color(0xFFFF9500),
        taskCount: 12,
        order: 3,
      ),
    ];
  }

  void _reorderCategories(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    setState(() {
      final item = _categories.removeAt(oldIndex);
      _categories.insert(newIndex, item);
      // Update order
      for (int i = 0; i < _categories.length; i++) {
        _categories[i] = _categories[i].copyWith(order: i);
      }
    });
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    Color selectedColor = AppColors.primary;
    IconData selectedIcon = Icons.folder_outlined;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusLarge),
          ),
          title: Text(
            'Thêm danh mục mới',
            style: R.styles.heading2(
              color: AppColors.black,
              weight: FontWeight.w700,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên danh mục',
                    labelStyle: R.styles.body(
                      size: 16,
                      color: AppColors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadiusMedium,
                      ),
                    ),
                  ),
                  style: R.styles.body(
                    size: 16,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingLarge),
                Text(
                  'Chọn màu',
                  style: R.styles.body(
                    size: 16,
                    weight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                Wrap(
                  spacing: AppDimensions.paddingMedium,
                  children: [
                    AppColors.primary,
                    const Color(0xFF10B981),
                    const Color(0xFF8B5CF6),
                    const Color(0xFFFF9500),
                    const Color(0xFFFF3B30),
                    const Color(0xFFFFC107),
                  ].map((color) {
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == color
                                ? AppColors.black
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Hủy',
                style: R.styles.body(
                  size: 16,
                  color: AppColors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    _categories.add(
                      Category(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text,
                        icon: selectedIcon,
                        color: selectedColor,
                        taskCount: 0,
                        order: _categories.length,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
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
          ],
        ),
      ),
    );
  }

  void _showCategoryMenu(BuildContext context, Category category) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.borderRadiusXLarge),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(
                'Chỉnh sửa',
                style: R.styles.body(
                  size: 16,
                  color: AppColors.black,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement edit
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: Text(
                'Xóa',
                style: R.styles.body(
                  size: 16,
                  color: AppColors.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _categories.removeWhere((c) => c.id == category.id);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectCategory(Category category) {
    if (widget.onCategorySelected != null) {
      widget.onCategorySelected!(category.name);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelectionMode = widget.onCategorySelected != null;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Danh Mục',
          style: R.styles.heading2(
            color: AppColors.black,
            weight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.white,
                size: 24,
              ),
            ),
            onPressed: _showAddCategoryDialog,
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
        ],
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        itemCount: _categories.length,
        onReorder: _reorderCategories,
        proxyDecorator: (child, index, animation) {
          return Material(
            color: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.transparent,
            child: child,
          );
        },
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = widget.selectedCategoryName == category.name;

          return _buildCategoryCard(category, index, isSelected);
        },
      ),
      bottomNavigationBar: isSelectionMode
          ? null
          : CustomBottomNavigationBar(
              currentIndex: 1,
              onTap: (index) {
                // Handle navigation if needed
              },
            ),
    );
  }

  Widget _buildCategoryCard(Category category, int index, bool isSelected) {
    return Container(
      key: ValueKey(category.id),
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.greyLight,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onCategorySelected != null
              ? () => _selectCategory(category)
              : null,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              children: [
                // Drag handle
                Icon(
                  Icons.drag_handle,
                  color: AppColors.grey,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
                // Category icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                // Category info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: R.styles.body(
                          size: 16,
                          weight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category.taskCount} công việc',
                        style: R.styles.body(
                          size: 14,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Menu button
                if (widget.onCategorySelected == null)
                  IconButton(
                    icon: const Icon(
                      Icons.more_vert,
                      color: AppColors.grey,
                    ),
                    onPressed: () => _showCategoryMenu(context, category),
                  )
                else if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
