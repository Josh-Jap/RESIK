import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/app_colors.dart';
import 'core/supabase_config.dart';
import 'admin/admin_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system overlay styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    if (SupabaseConfig.supabaseUrl != 'https://YOUR_PROJECT_ID.supabase.co') {
      await SupabaseConfig.init();
    }
  } catch (e) {
    debugPrint('Inisialisasi Supabase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const fontName = 'Plus Jakarta Sans';

    return MaterialApp(
      title: 'RESIK - Manajemen Sampah Perumahan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: fontName,
        scaffoldBackgroundColor: AppColors.scaffoldBg,
        primaryColor: AppColors.primaryGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          primary: AppColors.primaryGreen,
          secondary: AppColors.primaryMuted,
          surface: AppColors.cardBg,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.scaffoldBg,
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
          titleTextStyle: TextStyle(
            fontFamily: fontName,
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: fontName, color: AppColors.textPrimary),
          displayMedium: TextStyle(fontFamily: fontName, color: AppColors.textPrimary),
          displaySmall: TextStyle(fontFamily: fontName, color: AppColors.textPrimary),
          headlineLarge: TextStyle(fontFamily: fontName, color: AppColors.textPrimary),
          headlineMedium: TextStyle(fontFamily: fontName, color: AppColors.textPrimary),
          headlineSmall: TextStyle(fontFamily: fontName, color: AppColors.textPrimary),
          titleLarge: TextStyle(fontFamily: fontName, color: AppColors.textPrimary),
          titleMedium: TextStyle(fontFamily: fontName, color: AppColors.textPrimary),
          titleSmall: TextStyle(fontFamily: fontName, color: AppColors.textPrimary),
          bodyLarge: TextStyle(fontFamily: fontName, color: AppColors.textPrimary),
          bodyMedium: TextStyle(fontFamily: fontName, color: AppColors.textPrimary),
          bodySmall: TextStyle(fontFamily: fontName, color: AppColors.textSecondary),
          labelLarge: TextStyle(fontFamily: fontName, color: AppColors.textPrimary),
          labelMedium: TextStyle(fontFamily: fontName, color: AppColors.textSecondary),
          labelSmall: TextStyle(fontFamily: fontName, color: AppColors.textMuted),
        ),
      ),
      home: const AdminSplashScreen(),
    );
  }
}
