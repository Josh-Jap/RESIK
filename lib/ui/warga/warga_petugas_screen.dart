import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/resik_avatar_badge.dart';
import '../../backend/backend.dart';

class WargaPetugasScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const WargaPetugasScreen({super.key, this.onNavigateTab});

  @override
  State<WargaPetugasScreen> createState() => _WargaPetugasScreenState();
}

class _WargaPetugasScreenState extends State<WargaPetugasScreen> {
  final _searchController = TextEditingController();
  List<UserModel> _officers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOfficers();
  }

  Future<void> _loadOfficers() async {
    setState(() => _isLoading = true);
    final users = await SupabaseService.instance.getUsersByRole('petugas');
    if (mounted) {
      setState(() {
        _officers = users;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserModel> get _filteredOfficers {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _officers;
    return _officers.where((o) {
      final name = o.nameUsers.toLowerCase();
      final phone = o.displayPhone.toLowerCase();
      return name.contains(q) || phone.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredOfficers;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg, // #F5F3EA
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadOfficers,
          color: AppColors.primaryGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(color: AppColors.primaryGreen),
                    ),
                  )
                else if (list.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'Tidak ada data petugas',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                else
                  // Officers List
                  ...List.generate(list.length, (idx) {
                    final item = list[idx];
                    final String name = item.nameUsers.isNotEmpty
                        ? item.nameUsers
                        : (item.email ?? 'Petugas');
                    final phone = item.displayPhone;
                    final initials = item.initials;

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
                              initials,
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
                                  name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  phone,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Petugas Kebersihan',
                                  style: TextStyle(
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
                                  content: Text('Menghubungi $name ($phone)'),
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
      ),
    );
  }
}
