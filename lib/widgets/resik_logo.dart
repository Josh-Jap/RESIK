import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class ResikLogo extends StatelessWidget {
  final bool isDarkBackground;
  final double iconSize;
  final double titleSize;
  final double subtitleSize;
  final bool showText;

  const ResikLogo({
    super.key,
    this.isDarkBackground = false,
    this.iconSize = 72,
    this.titleSize = 22,
    this.subtitleSize = 9.5,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isDarkBackground ? Colors.white : AppColors.primaryGreen;
    final subtitleColor = isDarkBackground
        ? const Color(0xFFC7EBD6)
        : AppColors.textSecondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Circular badge with original RESIK vector icon
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: isDarkBackground
                ? const Color(0xFF2E6F5B)
                : AppColors.primaryGreen,
            shape: BoxShape.circle,
            boxShadow: isDarkBackground
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(
            child: SizedBox(
              width: iconSize * 0.65,
              height: iconSize * 0.65,
              child: Image.asset(
                'assets/icons/resik_icon.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to custom stack if asset hasn't hot-reloaded
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                        size: iconSize * 0.54,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Icon(
                          Icons.eco_rounded,
                          color: AppColors.accentMint,
                          size: iconSize * 0.28,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 12),
          Text(
            'RESIK',
            style: TextStyle(
              color: titleColor,
              fontSize: titleSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'MANAJEMEN SAMPAH PERUMAHAN',
            style: TextStyle(
              color: subtitleColor,
              fontSize: subtitleSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ],
    );
  }
}
