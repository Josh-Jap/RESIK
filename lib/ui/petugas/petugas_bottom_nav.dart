import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PetugasBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PetugasBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavItem> _items = [
    _NavItem(
      label: 'Beranda',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    _NavItem(
      label: 'Laporan',
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment_rounded,
    ),
    _NavItem(
      label: 'Jadwal',
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
    ),
    _NavItem(
      label: 'Akun',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBg, // #F5F3EA
        border: Border(
          top: BorderSide(
            color: AppColors.border, // #D9DDD7
            width: 1.0,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom
            : 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final isSelected = index == currentIndex;

          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              splashColor: AppColors.primaryGreen.withValues(alpha: 0.1),
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? item.activeIcon : item.icon,
                      size: 24,
                      color: isSelected
                          ? AppColors.primaryGreen  // #245C4A
                          : AppColors.textSecondary,// #7FA68C
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primaryGreen  // #245C4A
                            : AppColors.textSecondary,// #7FA68C
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
