import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'constants/app_constants.dart';
import 'res/fonts/sf_pro_typography_theme.dart';
import 'screens/splash_screen.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  // Khi build app, file .env được bundle vào assets, cần load từ assets bundle
  try {
    // Load từ assets bundle (file .env đã được thêm vào assets trong pubspec.yaml)
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Warning: Could not load .env file from assets: $e');
    debugPrint('Attempting to load from file system (debug mode)...');
    // Thử load từ file system (cho debug mode)
    try {
      await dotenv.load(fileName: ".env");
    } catch (e2) {
      debugPrint('Warning: Could not load .env file: $e2');
      debugPrint(
          'Make sure .env file exists and is included in assets in pubspec.yaml');
      // Không throw error, sẽ fallback trong SupabaseService hoặc sử dụng dart-define
    }
  }

  // Initialize Supabase (will read from .env or use provided values)
  try {
    await SupabaseService.initialize();
    debugPrint('✅ Supabase initialized successfully');

    // Verify credentials were loaded correctly
    final dartDefineUrl =
        const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    final envUrl = dotenv.env['SUPABASE_URL'];
    if (dartDefineUrl.isNotEmpty) {
      debugPrint('✅ Using credentials from --dart-define');
    } else if (envUrl != null && envUrl.isNotEmpty) {
      debugPrint('✅ Using credentials from .env file');
    } else {
      debugPrint('⚠️  Warning: No credentials found in dart-define or .env');
    }
  } catch (e) {
    debugPrint('❌ Error initializing Supabase: $e');
    debugPrint('⚠️  App will continue but Supabase features may not work');
    debugPrint(
        '💡 Make sure .env file exists with SUPABASE_URL and SUPABASE_ANON_KEY');
    debugPrint(
        '💡 Or build with --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...');
    // App will still run but Supabase features won't work
    // User will see error when trying to use Supabase features
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Management',
      theme: ThemeData(
        // ===== Colors =====screen.png
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        brightness: Brightness.light,

        // ===== Typography - SF Pro Font =====
        // Apply SF Pro fonts to entire app
        textTheme: SFProTypographyTheme.createTextTheme(),

        // ===== AppBar Theme =====
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: SFProHeadings.h2.copyWith(
            color: AppColors.white,
          ),
        ),

        // ===== Button Themes =====
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            textStyle: SFProBody.mediumBold,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLarge,
              vertical: AppDimensions.paddingMedium,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusMedium),
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: SFProBody.mediumBold,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLarge,
              vertical: AppDimensions.paddingMedium,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusMedium),
            ),
            side: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: SFProBody.mediumBold,
          ),
        ),

        // ===== Input Decoration Theme =====
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusMedium),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusMedium),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusMedium),
            borderSide: const BorderSide(color: AppColors.error, width: 1),
          ),
          labelStyle: SFProBody.medium.copyWith(
            color: AppColors.grey,
          ),
          hintStyle: SFProBody.regular.copyWith(
            color: AppColors.grey,
          ),
        ),

        // ===== Card Theme =====
        cardTheme: CardTheme(
          color: AppColors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusLarge),
          ),
        ),

        // ===== Chip Theme =====
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.greyLight,
          disabledColor: AppColors.greyLight,
          selectedColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingSmall,
            vertical: AppDimensions.paddingXSmall,
          ),
          labelStyle: SFProBody.smallRegular,
          secondaryLabelStyle: SFProBody.smallRegular,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusMedium),
          ),
        ),

        // ===== Dialog Theme =====
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusLarge),
          ),
          backgroundColor: AppColors.white,
          elevation: 8,
          titleTextStyle: SFProHeadings.h2,
          contentTextStyle: SFProBody.regular,
        ),

        // ===== Bottom Sheet Theme =====
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: AppColors.white,
          elevation: 8,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.borderRadiusXLarge),
            ),
          ),
        ),

        // ===== Floating Action Button Theme =====
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusMedium),
          ),
          elevation: 4,
        ),

        // ===== List Tile Theme =====
        listTileTheme: ListTileThemeData(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingSmall,
          ),
          titleTextStyle: SFProBody.medium.copyWith(
            color: AppColors.black,
          ),
          subtitleTextStyle: SFProBody.smallRegular.copyWith(
            color: AppColors.grey,
          ),
        ),

        // ===== Bottom Navigation Bar Theme =====
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.grey,
          selectedLabelStyle: SFProCaptions.medium,
          unselectedLabelStyle: SFProCaptions.regular,
          elevation: 8,
        ),

        // ===== Tab Bar Theme =====
        tabBarTheme: TabBarTheme(
          labelStyle: SFProBody.mediumBold,
          unselectedLabelStyle: SFProBody.medium,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.grey,
          indicator: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.primary,
                width: 3,
              ),
            ),
          ),
        ),

        // ===== Snackbar Theme =====
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.greyDark,
          contentTextStyle: SFProBody.regular.copyWith(
            color: AppColors.white,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusMedium),
          ),
          elevation: 8,
        ),

        // ===== Progress Indicator Theme =====
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: AppColors.greyLight,
        ),

        // ===== Divider Theme =====
        dividerTheme: DividerThemeData(
          color: AppColors.greyLight,
          thickness: 1,
          space: AppDimensions.paddingMedium,
        ),

        // ===== Switch Theme =====
        switchTheme: SwitchThemeData(
          thumbColor: const MaterialStatePropertyAll(AppColors.primary),
          trackColor: const MaterialStatePropertyAll(AppColors.greyLight),
        ),

        // ===== Checkbox Theme =====
        checkboxTheme: CheckboxThemeData(
          fillColor: const MaterialStatePropertyAll(AppColors.primary),
          checkColor: const MaterialStatePropertyAll(AppColors.white),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusSmall),
          ),
        ),

        // ===== Radio Theme =====
        radioTheme: RadioThemeData(
          fillColor: const MaterialStatePropertyAll(AppColors.primary),
        ),

        // ===== Scaffold Background =====
        scaffoldBackgroundColor: AppColors.white,

        // ===== Splash Color =====
        splashColor: AppColors.primary.withOpacity(0.1),
        highlightColor: AppColors.primary.withOpacity(0.1),
        hoverColor: AppColors.primary.withOpacity(0.05),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
