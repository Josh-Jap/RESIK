import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../backend/backend.dart';
import '../widgets/resik_avatar_badge.dart';
import 'admin_tambah_petugas_screen.dart';

class AdminPetugasScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const AdminPetugasScreen({super.key, this.onNavigateTab});

  @override
  State<AdminPetugasScreen> createState() => _AdminPetugasScreenState();
}

class _AdminPetugasScreenState extends State<AdminPetugasScreen> {
  final _searchController = TextEditingController();
  final List<Map<String, dynamic>> _petugasList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPetugas();
  }

  Future<void> _fetchPetugas() async {
    setState(() => _isLoading = true);
    try {
      final list = await SupabaseService.instance.getUsersByRole('petugas');
      if (mounted) {
        setState(() {
          _petugasList.clear();
          for (final p in list) {
            _petugasList.add({
              'id_users': p.idUsers,
              'initials': p.initials,
              'name': p.nameUsers,
              'phone': p.displayPhone,
              'email': p.email ?? '-',
              'role': p.role,
              'area': 'Petugas Kebersihan',
              'isActive': true,
            });
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPetugasDetail(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.12),
                    child: Text(
                      item['initials'] ?? 'P',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] ?? 'Petugas',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (item['isActive'] == true)
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: (item['isActive'] == true)
                                  ? Colors.green.shade200
                                  : Colors.red.shade200,
                            ),
                          ),
                          child: Text(
                            (item['isActive'] == true)
                                ? 'Status: Aktif'
                                : 'Status: Non-Aktif',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: (item['isActive'] == true)
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Detail List Items
              _buildDetailRow(
                icon: Icons.phone_outlined,
                label: 'Nomor Telepon',
                value: item['phone'] ?? '-',
              ),
              const SizedBox(height: 14),
              _buildDetailRow(
                icon: Icons.email_outlined,
                label: 'Email Akun',
                value: item['email'] ?? '-',
              ),
              const SizedBox(height: 14),
              _buildDetailRow(
                icon: Icons.badge_outlined,
                label: 'Peran / Role',
                value: (item['role'] ?? 'petugas').toString().toUpperCase(),
              ),
              const SizedBox(height: 14),
              _buildDetailRow(
                icon: Icons.cleaning_services_outlined,
                label: 'Penugasan',
                value: item['area'] ?? 'Petugas Kebersihan',
              ),
              if (item['id_users'] != null) ...[
                const SizedBox(height: 14),
                _buildDetailRow(
                  icon: Icons.fingerprint_rounded,
                  label: 'ID Sistem Database',
                  value: '#${item['id_users']}',
                ),
              ],

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredPetugas {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _petugasList;
    return _petugasList.where((p) {
      return (p['name'] as String).toLowerCase().contains(query) ||
          (p['area'] as String).toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredPetugas;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_petugas_admin',
        onPressed: () async {
          final res = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AdminTambahPetugasScreen(),
            ),
          );
          if (res != null) {
            await _fetchPetugas();
            if (res is Map<String, dynamic> &&
                !_petugasList.any((p) => p['name'] == res['name'])) {
              setState(() {
                _petugasList.insert(0, Map<String, dynamic>.from(res));
              });
            }
          }
        },
        backgroundColor: AppColors.primaryGreen,
        elevation: 3,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchPetugas,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Data Petugas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Kelola keaktifan dan penugasan tim lapangan.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  ResikAvatarBadge(
                    onTap: () => widget.onNavigateTab?.call(5),
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
                  fillColor: Colors.white,
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
                      'Belum ada petugas terdaftar.\nKlik tombol + di bawah untuk mendaftarkan petugas baru.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                )
              else
                // Officers List
                ...List.generate(list.length, (idx) {
                final item = list[idx];
                final isActive = item['isActive'] as bool;

                return InkWell(
                  onTap: () => _showPetugasDetail(item),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              AppColors.cardSubtle,
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
                        Switch(
                          value: isActive,
                          activeThumbColor: AppColors.primaryGreen,
                          onChanged: (val) {
                            setState(() {
                              item['isActive'] = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
    ),
  );
  }
}
