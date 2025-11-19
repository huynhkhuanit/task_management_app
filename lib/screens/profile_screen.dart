import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../widgets/custom_switch.dart';
import '../widgets/notification_badge.dart';
import '../utils/navigation_helper.dart';
import '../services/profile_service.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';
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
  final _profileService = ProfileService();
  final _notificationService = NotificationService();
  bool _isDarkMode = false;
  String _selectedLanguage = 'Tiếng Việt';
  String _selectedLanguageCode = 'vi';
  String? _fullName;
  String? _email;
  String? _phoneNumber;
  String? _avatarUrl;
  int _unreadNotificationCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.getProfile();
      final user = SupabaseService.currentUser;

      // Load unread notification count
      int unreadCount = 0;
      try {
        unreadCount = await _notificationService.getUnreadCount();
      } catch (e) {
        // Ignore error, keep count as 0
      }

      final lang = profile['language'] as String? ?? 'vi';

      setState(() {
        _fullName = profile['full_name'] as String?;
        _phoneNumber = profile['phone_number'] as String?;
        _avatarUrl = profile['avatar_url'] as String?;
        _email = user?.email;
        _isDarkMode = profile['dark_mode'] as bool? ?? false;
        _selectedLanguageCode = lang;
        _selectedLanguage = _getLanguageName(lang);
        _unreadNotificationCount = unreadCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Use default values if error
      final user = SupabaseService.currentUser;
      setState(() {
        _email = user?.email;
        _fullName = user?.userMetadata?['full_name'] as String?;
      });
    }
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'vi':
        return 'Tiếng Việt';
      case 'en':
        return 'English';
      case 'zh':
        return '中文';
      case 'ja':
        return '日本語';
      default:
        return 'Tiếng Việt';
    }
  }

  String _getLanguageCode(String name) {
    switch (name) {
      case 'Tiếng Việt':
        return 'vi';
      case 'English':
        return 'en';
      case '中文':
        return 'zh';
      case '日本語':
        return 'ja';
      default:
        return 'vi';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFFF7F9FC),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
                            image: _avatarUrl != null && _avatarUrl!.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(_avatarUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _avatarUrl == null || _avatarUrl!.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppColors.black,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              final result =
                                  await NavigationHelper.pushSlideTransition(
                                context,
                                EditProfileScreen(
                                  initialName: _fullName ?? '',
                                  initialEmail: _email ?? '',
                                  initialPhone: _phoneNumber ?? '',
                                ),
                              );
                              if (result == true) {
                                _loadProfile();
                              }
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
                      _fullName ?? 'Chưa có tên',
                      style: R.styles.heading2(
                        color: AppColors.black,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),

                    // Email
                    Text(
                      _email ?? 'Chưa có email',
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
                      onTap: () async {
                        final result =
                            await NavigationHelper.pushSlideTransition(
                          context,
                          EditProfileScreen(
                            initialName: _fullName ?? '',
                            initialEmail: _email ?? '',
                            initialPhone: _phoneNumber ?? '',
                          ),
                        );
                        if (result == true) {
                          _loadProfile();
                        }
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
                      onChanged: (value) async {
                        try {
                          await _profileService.updateProfile(darkMode: value);
                          setState(() {
                            _isDarkMode = value;
                          });
                          // TODO: Implement dark mode theme switching
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Lỗi cập nhật chế độ tối: ${e.toString()}'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),

                    // Notifications
                    _buildMenuItemWithBadge(
                      icon: Icons.notifications_outlined,
                      title: 'Thông báo',
                      badgeCount: _unreadNotificationCount,
                      onTap: () async {
                        await NavigationHelper.pushSlideTransition(
                          context,
                          const NotificationsScreen(),
                        );
                        // Reload notification count after returning
                        _loadProfile();
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

  Future<void> _performLogout() async {
    try {
      // Sign out from Supabase
      await SupabaseService.signOut();

      // Navigate to login screen and clear navigation stack
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đăng xuất: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
                        onChanged: (value) async {
                          final languageCode = _getLanguageCode(value!);
                          try {
                            await _profileService.updateProfile(
                                language: languageCode);
                            setModalState(() {
                              _selectedLanguage = value;
                            });
                            setState(() {
                              _selectedLanguage = value;
                              _selectedLanguageCode = languageCode;
                            });
                            Navigator.of(context).pop();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Đã chọn: $value'),
                                ),
                              );
                            }
                            // TODO: Implement language change logic (localization)
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Lỗi cập nhật ngôn ngữ: ${e.toString()}'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                        activeColor: AppColors.primary,
                      ),
                      title: Text(
                        language,
                        style: R.styles.body(
                          size: 16,
                          color: AppColors.black,
                          weight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      onTap: () async {
                        final languageCode = _getLanguageCode(language);
                        try {
                          await _profileService.updateProfile(
                              language: languageCode);
                          setModalState(() {
                            _selectedLanguage = language;
                          });
                          setState(() {
                            _selectedLanguage = language;
                            _selectedLanguageCode = languageCode;
                          });
                          Navigator.of(context).pop();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã chọn: $language'),
                              ),
                            );
                          }
                          // TODO: Implement language change logic (localization)
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Lỗi cập nhật ngôn ngữ: ${e.toString()}'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
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
