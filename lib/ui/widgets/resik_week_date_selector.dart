import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ResikWeekDateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const ResikWeekDateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  static const List<String> _monthNames = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _dayNames = [
    'Min',
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
  ];

  DateTime get _startOfWeek {
    final weekday = selectedDate.weekday; // 1 (Mon) - 7 (Sun)
    // Align so Senin is start of week
    return selectedDate.subtract(Duration(days: weekday - 1));
  }

  int get _weekOfMonth {
    return ((selectedDate.day - 1) / 7).floor() + 1;
  }

  void _pickCustomDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = _startOfWeek;
    final end = start.add(const Duration(days: 6));
    final monthName = _monthNames[selectedDate.month];
    final weekNum = _weekOfMonth;

    final weekRangeText =
        '${start.day} ${_monthNames[start.month].substring(0, 3)} - ${end.day} ${_monthNames[end.month].substring(0, 3)} ${end.year}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Navigation Arrows, Week Indicator, & Calendar Button
          Row(
            children: [
              // Prev Week Button
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  onDateSelected(selectedDate.subtract(const Duration(days: 7)));
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.cardSubtle,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Week & Range Label
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Minggu ke-$weekNum $monthName',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      weekRangeText,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Next Week Button
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  onDateSelected(selectedDate.add(const Duration(days: 7)));
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.cardSubtle,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Pick Specific Date Icon Button
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _pickCustomDate(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    size: 18,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 7-Day Horizontal Strip for the Selected Week (Senin s/d Minggu)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayDate = start.add(Duration(days: index));
              final isSelected = dayDate.year == selectedDate.year &&
                  dayDate.month == selectedDate.month &&
                  dayDate.day == selectedDate.day;

              final isToday = dayDate.year == DateTime.now().year &&
                  dayDate.month == DateTime.now().month &&
                  dayDate.day == DateTime.now().day;

              final dayLabel = _dayNames[dayDate.weekday % 7];

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => onDateSelected(dayDate),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryGreen
                            : (isToday
                                ? AppColors.accentMint.withValues(alpha: 0.15)
                                : AppColors.scaffoldBg),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryGreen
                              : (isToday
                                  ? AppColors.accentMint
                                  : AppColors.border),
                          width: isToday && !isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            dayLabel,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${dayDate.day}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? Colors.white
                                  : (isToday
                                      ? AppColors.primaryGreen
                                      : AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
