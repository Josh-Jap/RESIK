import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ResikAvatarBadge extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;

  const ResikAvatarBadge({
    super.key,
    this.size = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.primaryGreen,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SizedBox(
            width: size * 0.62,
            height: size * 0.62,
            child: Image.asset(
              'assets/icons/resik_icon.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.eco_rounded,
                color: AppColors.accentMint,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
