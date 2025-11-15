import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../models/category_model.dart';

class AddCategoryScreen extends StatefulWidget {
  final Category? categoryToEdit;

  const AddCategoryScreen({
    Key? key,
    this.categoryToEdit,
  }) : super(key: key);

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  Color _selectedColor = AppColors.primary;
  IconData _selectedIcon = Icons.work_outline;

  final List<Color> _colors = [
    AppColors.primary, // Blue
    const Color(0xFF10B981), // Mint green
    const Color(0xFFFF9500), // Orange
    const Color(0xFFFF3B30), // Red
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFF84CC16), // Lime green
    const Color(0xFFFFC107), // Amber
    const Color(0xFF6366F1), // Indigo
  ];

  final List<IconData> _icons = [
    Icons.work_outline,
    Icons.person_outline,
    Icons.star_outline,
    Icons.bookmark_outline,
    Icons.shopping_cart_outlined,
    Icons.flight_outlined,
    Icons.favorite_outline,
    Icons.home_outlined,
    Icons.lightbulb_outline,
    Icons.school_outlined,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.categoryToEdit != null) {
      _nameController.text = widget.categoryToEdit!.name;
      _selectedColor = widget.categoryToEdit!.color;
      _selectedIcon = widget.categoryToEdit!.icon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên danh mục')),
      );
      return;
    }

    final category = Category(
      id: widget.categoryToEdit?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      color: _selectedColor,
      taskCount: widget.categoryToEdit?.taskCount ?? 0,
      order: widget.categoryToEdit?.order ?? 0,
    );

    Navigator.of(context).pop(category);
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
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: _handleCancel,
        ),
        title: Text(
          widget.categoryToEdit != null
              ? 'Chỉnh sửa danh mục'
              : 'Thêm Danh mục Mới',
          style: R.styles.heading2(
            color: AppColors.black,
            weight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
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
                    // Category Name Section
                    Text(
                      'Tên danh mục',
                      style: R.styles.body(
                        size: 16,
                        weight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    TextField(
                      controller: _nameController,
                      style: R.styles.body(
                        size: 16,
                        color: AppColors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ví dụ: Công việc, Cá nhân...',
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

                    // Color Selection Section
                    Text(
                      'Chọn màu',
                      style: R.styles.body(
                        size: 16,
                        weight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    // First row of colors (6 colors)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final colorWidth = 48.0;
                        final totalWidth = constraints.maxWidth;
                        final totalColorWidth = colorWidth * 6;
                        final spacing = (totalWidth - totalColorWidth) / 5;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildColorOption(_colors[0]),
                            SizedBox(width: spacing),
                            _buildColorOption(_colors[1]),
                            SizedBox(width: spacing),
                            _buildColorOption(_colors[2]),
                            SizedBox(width: spacing),
                            _buildColorOption(_colors[3]),
                            SizedBox(width: spacing),
                            _buildColorOption(_colors[4]),
                            SizedBox(width: spacing),
                            _buildColorOption(_colors[5]),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    // Second row of colors (2 colors - left and right)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final colorWidth = 48.0;
                        final totalWidth = constraints.maxWidth;
                        final totalColorWidth = colorWidth * 6;
                        final spacing = (totalWidth - totalColorWidth) / 5;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildColorOption(_colors[6]),
                            SizedBox(width: spacing),
                            _buildColorOption(_colors[7]),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingLarge),

                    // Icon Selection Section
                    Text(
                      'Chọn Icon',
                      style: R.styles.body(
                        size: 16,
                        weight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    // Grid of icons (2 rows, 5 columns)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: AppDimensions.paddingMedium,
                        mainAxisSpacing: AppDimensions.paddingMedium,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: _icons.length,
                      itemBuilder: (context, index) {
                        return _buildIconOption(_icons[index]);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
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
                        minimumSize: const Size(0, 48),
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
                  const SizedBox(width: AppDimensions.paddingMedium),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingSmall,
                        ),
                        minimumSize: const Size(0, 48),
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

  Widget _buildColorOption(Color color) {
    final isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: isSelected
            ? Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white,
                      width: 3,
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildIconOption(IconData icon) {
    final isSelected = _selectedIcon == icon;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIcon = icon;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? _selectedColor : AppColors.white,
          borderRadius: BorderRadius.circular(
            AppDimensions.borderRadiusMedium,
          ),
          border: Border.all(
            color: isSelected ? _selectedColor : AppColors.greyLight,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.white : AppColors.greyDark,
          size: 24,
        ),
      ),
    );
  }
}
