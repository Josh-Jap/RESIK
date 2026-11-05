import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/resik_avatar_badge.dart';

class WargaPetugasScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const WargaPetugasScreen({super.key, this.onNavigateTab});

  @override
  State<WargaPetugasScreen> createState() => _WargaPetugasScreenState();
}

class _WargaPetugasScreenState extends State<WargaPetugasScreen> {
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _officers = [
    {
      'initials': 'BS',
      'name': 'Budi Santoso',
      'phone': '0812-3456-7890',
      'area': 'Wilayah: Blok A–C',
      'role': 'Petugas Armada 1',
    },
    {
      'initials': 'SA',
      'name': 'Siti Aminah',
      'phone': '0813-9876-5432',
      'area': 'Wilayah: Blok D–F',
      'role': 'Petugas Armada 2',
    },
    {
      'initials': 'JW',
      'name': 'Joko Widodo',
      'phone': '0811-1111-2222',
      'area': 'Wilayah: Taman Utama',
      'role': 'Pemeliharaan Area',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredOfficers {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _officers;
    return _officers.where((o) {
      return (o['name'] as String).toLowerCase().contains(q) ||
          (o['area'] as String).toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredOfficers;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg, // #F5F3EA
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Data Petugas',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary, // #252A27
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Kenali petugas kebersihan yang bertugas di area Anda.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary, // #7FA68C
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ResikAvatarBadge(
                    onTap: () => widget.onNavigateTab?.call(4),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Search Bar
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.cardBg,
                  hintText: 'Cari nama petugas...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Officers List
              ...List.generate(list.length, (idx) {
                final item = list[idx];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg, // #FFFFFF
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border), // #D9DDD7
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.cardSubtle,
                        child: Text(
                          item['initials'],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['phone'],
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['area'],
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Menghubungi ${item['name']} (${item['phone']})'),
                              backgroundColor: AppColors.primaryGreen,
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.phone_outlined,
                            size: 18,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
