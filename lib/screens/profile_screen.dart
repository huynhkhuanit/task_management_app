import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../widgets/custom_switch.dart';
import '../widgets/notification_badge.dart';
import '../utils/navigation_helper.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'notifications_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;
  String _selectedLanguage = 'Tiếng Việt';

  int _getUnreadNotificationCount() {
    // TODO: Replace with actual notification count from service/state
    // For now, return a sample count (4 unread notifications)
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.only(
                  top: AppDimensions.paddingLarge,
                  bottom: AppDimensions.paddingXLarge,
                ),
                child: Text(
                  'Tài khoản',
                  style: R.styles.heading2(
                    color: AppColors.black,
                    weight: FontWeight.w700,
                  ),
                ),
              ),

              // Profile Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLarge,
                ),
                child: Column(
                  children: [
                    // Avatar with edit button
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE5D4), // Light orange
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.black,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              NavigationHelper.pushSlideTransition(
                                context,
                                const EditProfileScreen(
                                  initialName: 'Lê Huỳnh Đức',
                                  initialEmail: 'lehuynhduc@email.com',
                                ),
                              );
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 16,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),

                    // Name
                    Text(
                      'Lê Huỳnh Đức',
                      style: R.styles.heading2(
                        color: AppColors.black,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),

                    // Email
                    Text(
                      'lehuynhduc@email.com',
                      style: R.styles.body(
                        size: 14,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXLarge),
                  ],
                ),
              ),

              // Menu Items
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLarge,
                ),
                child: Column(
                  children: [
                    // Edit Information
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'Chỉnh sửa thông tin',
                      onTap: () {
                        NavigationHelper.pushSlideTransition(
                          context,
                          const EditProfileScreen(
                            initialName: 'Lê Huỳnh Đức',
                            initialEmail: 'lehuynhduc@email.com',
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),

                    // Change Password
                    _buildMenuItem(
                      icon: Icons.lock_outline,
                      title: 'Đổi mật khẩu',
                      onTap: () {
                        NavigationHelper.pushSlideTransition(
                          context,
                          const ChangePasswordScreen(),
                        );
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),

                    // Dark Mode
                    _buildMenuItemWithToggle(
                      icon: Icons.dark_mode_outlined,
                      title: 'Chế độ Tối',
                      value: _isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          _isDarkMode = value;
                        });
                        // TODO: Implement dark mode
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),

                    // Notifications
                    _buildMenuItemWithBadge(
                      icon: Icons.notifications_outlined,
                      title: 'Thông báo',
                      badgeCount: _getUnreadNotificationCount(),
                      onTap: () {
                        NavigationHelper.pushSlideTransition(
                          context,
                          const NotificationsScreen(),
                        );
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),

                    // Language
                    _buildMenuItemWithValue(
                      icon: Icons.language_outlined,
                      title: 'Ngôn ngữ',
                      value: _selectedLanguage,
                      onTap: () {
                        _showLanguageSelection();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXLarge),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLarge,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Handle logout
                      _showLogoutDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFFFF5F5), // Very light red
                      foregroundColor: AppColors.error,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingMedium,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadiusMedium,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.logout,
                          size: 20,
                        ),
                        const SizedBox(width: AppDimensions.paddingSmall),
                        Text(
                          'Đăng xuất',
                          style: R.styles.body(
                            size: 16,
                            weight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXLarge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXLarge),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppColors.greyLight.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.2),
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusSmall),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: Text(
                title,
                style: R.styles.body(
                  size: 16,
                  color: AppColors.black,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.grey,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemWithBadge({
    required IconData icon,
    required String title,
    required int badgeCount,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXLarge),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppColors.greyLight.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            NotificationBadge(
              count: badgeCount,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.2),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusSmall),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: Text(
                title,
                style: R.styles.body(
                  size: 16,
                  color: AppColors.black,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.grey,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemWithToggle({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyLight.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.2),
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusSmall),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Text(
              title,
              style: R.styles.body(
                size: 16,
                color: AppColors.black,
              ),
            ),
          ),
          CustomSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemWithValue({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppColors.greyLight.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.2),
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusSmall),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: Text(
                title,
                style: R.styles.body(
                  size: 16,
                  color: AppColors.black,
                ),
              ),
            ),
            Text(
              value,
              style: R.styles.body(
                size: 14,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            Icon(
              Icons.chevron_right,
              color: AppColors.grey,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Đăng xuất',
            style: R.styles.heading3(
              color: AppColors.black,
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn đăng xuất?',
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
                _performLogout();
              },
              child: Text(
                'Đăng xuất',
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

  void _performLogout() {
    // TODO: Clear user session, tokens, etc.
    // Navigate to login screen and clear navigation stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  void _showLanguageSelection() {
    final List<String> languages = ['Tiếng Việt', 'English', '中文', '日本語'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.borderRadiusXLarge),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chọn ngôn ngữ',
                    style: R.styles.heading2(
                      color: AppColors.black,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  ...languages.map((language) {
                    final isSelected = language == _selectedLanguage;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Radio<String>(
                        value: language,
                        groupValue: _selectedLanguage,
                        onChanged: (value) {
                          setModalState(() {
                            _selectedLanguage = value!;
                          });
                          setState(() {
                            _selectedLanguage = value!;
                          });
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã chọn: $language'),
                            ),
                          );
                          // TODO: Implement language change logic
                        },
                        activeColor: AppColors.primary,
                      ),
                      title: Text(
                        language,
                        style: R.styles.body(
                          size: 16,
                          color: AppColors.black,
                          weight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        setModalState(() {
                          _selectedLanguage = language;
                        });
                        setState(() {
                          _selectedLanguage = language;
                        });
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã chọn: $language'),
                          ),
                        );
                        // TODO: Implement language change logic
                      },
                    );
                  }),
                  const SizedBox(height: AppDimensions.paddingMedium),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
