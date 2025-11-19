import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../models/category_model.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../utils/navigation_helper.dart';
import '../services/category_service.dart';
import 'add_category_screen.dart';

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
  final _categoryService = CategoryService();
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final categories = await _categoryService.getCategories();

      // Note: Task count is set to 0 as Task model doesn't include categoryId
      // This can be updated later when Task model includes categoryId field

      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Silently handle error - UI will show empty state
      }
    }
  }

  Future<void> _reorderCategories(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    // Update local state immediately for better UX
    setState(() {
      final item = _categories.removeAt(oldIndex);
      _categories.insert(newIndex, item);
      // Update order
      for (int i = 0; i < _categories.length; i++) {
        _categories[i] = _categories[i].copyWith(order: i);
      }
    });

    // Update order in database
    try {
      final categoryIds = _categories.map((c) => c.id).toList();
      await _categoryService.reorderCategories(categoryIds);
    } catch (e) {
      // Reload on error to sync with database
      _loadCategories();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi sắp xếp lại danh mục: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showAddCategoryDialog() async {
    final result = await NavigationHelper.pushSlideTransition<Category>(
      context,
      const AddCategoryScreen(),
    );

    if (result != null) {
      // Reload categories from database to get the newly created category
      await _loadCategories();
    }
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
              onTap: () async {
                Navigator.pop(context);
                final result =
                    await NavigationHelper.pushSlideTransition<Category>(
                  context,
                  AddCategoryScreen(categoryToEdit: category),
                );

                if (result != null) {
                  // Reload categories from database
                  await _loadCategories();
                }
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
              onTap: () async {
                Navigator.pop(context);
                try {
                  await _categoryService.deleteCategory(category.id);
                  // Reload categories from database
                  await _loadCategories();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã xóa danh mục'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi xóa danh mục: ${e.toString()}'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
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

  void _editCategory(Category category) async {
    final result = await NavigationHelper.pushSlideTransition<Category>(
      context,
      AddCategoryScreen(categoryToEdit: category),
    );

    if (result != null) {
      // Reload categories from database
      await _loadCategories();
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : _categories.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 64,
                          color: AppColors.grey.withOpacity(0.4),
                        ),
                        const SizedBox(height: AppDimensions.paddingLarge),
                        Text(
                          'Chưa có danh mục nào',
                          style: R.styles.body(
                            size: 16,
                            color: AppColors.grey,
                            weight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.paddingSmall),
                        Text(
                          'Nhấn nút + để thêm danh mục mới',
                          style: R.styles.body(
                            size: 14,
                            color: AppColors.grey,
                            weight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : isSelectionMode
                  ? ListView.builder(
                      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected =
                            widget.selectedCategoryName == category.name;

                        return _buildCategoryCard(category, index, isSelected);
                      },
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                      itemCount: _categories.length,
                      onReorder: _reorderCategories,
                      proxyDecorator: (child, index, animation) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            final double animValue =
                                Curves.easeInOut.transform(animation.value);
                            return Material(
                              color: Colors.transparent,
                              elevation: 8 + (animValue * 8),
                              shadowColor: AppColors.primary.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.borderRadiusLarge),
                              clipBehavior: Clip.antiAlias,
                              child: Opacity(
                                opacity: 0.9 + (animValue * 0.1),
                                child: child,
                              ),
                            );
                          },
                          child: child,
                        );
                      },
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected =
                            widget.selectedCategoryName == category.name;

                        return _buildCategoryCard(category, index, isSelected);
                      },
                      buildDefaultDragHandles: false,
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
    final isSelectionMode = widget.onCategorySelected != null;

    final cardContent = Container(
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
        child: GestureDetector(
          onDoubleTap: () {
            _editCategory(category);
          },
          onTap: () {
            if (widget.onCategorySelected != null) {
              _selectCategory(category);
            }
            // Single tap does nothing in normal mode (only double tap opens edit)
          },
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              children: [
                // Drag handle icon - only show when not in selection mode
                if (!isSelectionMode)
                  Icon(
                    Icons.drag_handle,
                    color: AppColors.grey,
                    size: 20,
                  ),
                if (!isSelectionMode)
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
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category.name,
                        style: R.styles.body(
                          size: 16,
                          weight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${category.taskCount} công việc',
                        style: R.styles.body(
                          size: 14,
                          color: AppColors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Selection indicator or menu button
                if (widget.onCategorySelected == null)
                  GestureDetector(
                    onTap: () {
                      _showCategoryMenu(context, category);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.more_vert,
                        color: AppColors.grey,
                      ),
                    ),
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

    // Wrap with ReorderableDragStartListener only when not in selection mode
    if (isSelectionMode) {
      return cardContent;
    } else {
      return ReorderableDragStartListener(
        key: ValueKey(category.id),
        index: index,
        child: cardContent,
      );
    }
  }
}
