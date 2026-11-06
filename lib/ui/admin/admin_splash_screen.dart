import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/resik_logo.dart';
import 'admin_login_screen.dart';

class AdminSplashScreen extends StatefulWidget {
  const AdminSplashScreen({super.key});

  @override
  State<AdminSplashScreen> createState() => _AdminSplashScreenState();
}

class _AdminSplashScreenState extends State<AdminSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();

    _timer = Timer(const Duration(seconds: 3), _goToLogin);
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim, secondAnim) => const AdminLoginScreen(),
        transitionsBuilder: (context, anim, secondAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _goToLogin,
      child: Scaffold(
        backgroundColor: AppColors.primaryDark,
        body: Center(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: const ResikLogo(
                    isDarkBackground: true,
                    iconSize: 84,
                    titleSize: 28,
                    subtitleSize: 11,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
