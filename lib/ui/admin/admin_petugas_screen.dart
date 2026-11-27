import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../backend/backend.dart';
import '../widgets/resik_avatar_badge.dart';
import '../widgets/resik_call_dialog.dart';
import 'admin_tambah_petugas_screen.dart';

class AdminPetugasScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const AdminPetugasScreen({super.key, this.onNavigateTab});

  @override
  State<AdminPetugasScreen> createState() => _AdminPetugasScreenState();
}

class _AdminPetugasScreenState extends State<AdminPetugasScreen> {
  final _searchController = TextEditingController();
  // 0: Semua, 1: Petugas, 2: Warga
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _allUsers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final petugasList = await SupabaseService.instance.getUsersByRole('petugas');
      final wargaList = await SupabaseService.instance.getUsersByRole('warga');

      final List<Map<String, dynamic>> temp = [];

      for (final p in petugasList) {
        final active = await SupabaseService.instance.isUserActive(p.idUsers, email: p.email);
        temp.add({
          'id_users': p.idUsers,
          'initials': p.initials,
          'name': p.nameUsers,
          'phone': p.displayPhone,
          'email': p.email ?? '-',
          'role': 'petugas',
          'roleLabel': 'Petugas',
          'area': p.housing?.nameHouse ?? 'Petugas Kebersihan',
          'isActive': active,
        });
      }

      for (final w in wargaList) {
        final active = await SupabaseService.instance.isUserActive(w.idUsers, email: w.email);
        temp.add({
          'id_users': w.idUsers,
          'initials': w.initials,
          'name': w.nameUsers,
          'phone': w.displayPhone,
          'email': w.email ?? '-',
          'role': 'warga',
          'roleLabel': 'Warga',
          'area': w.housing?.nameHouse ?? 'Warga Perumahan',
          'isActive': active,
        });
      }

      if (mounted) {
        setState(() {
          _allUsers.clear();
          _allUsers.addAll(temp);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleUserActiveStatus(Map<String, dynamic> item) {
    final currentStatus = item['isActive'] as bool;
    final newStatus = !currentStatus;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          newStatus ? 'Aktifkan Pengguna' : 'Nonaktifkan Pengguna',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          newStatus
              ? 'Apakah Anda ingin mengaktifkan kembali akun "${item['name']}"?'
              : 'Apakah Anda yakin ingin menonaktifkan akun "${item['name']}"? Pengguna tidak akan dapat mengakses sistem sementara waktu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final userId = item['id_users'] as int?;
              if (userId != null) {
                await SupabaseService.instance.toggleUserActiveStatus(userId, newStatus);
              }
              setState(() {
                item['isActive'] = newStatus;
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Akun "${item['name']}" berhasil ${newStatus ? 'diaktifkan' : 'dinonaktifkan'}!',
                    ),
                    backgroundColor: newStatus ? AppColors.primaryGreen : AppColors.danger,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus ? AppColors.primaryGreen : AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: Text(newStatus ? 'Aktifkan' : 'Nonaktifkan'),
          ),
        ],
      ),
    );
  }

  void _showUserDetail(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final isActive = item['isActive'] as bool;
            final isPetugas = item['role'] == 'petugas';

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
                        backgroundColor: (isPetugas ? AppColors.primaryGreen : const Color(0xFF2B6CB0))
                            .withValues(alpha: 0.12),
                        child: Text(
                          item['initials'] ?? 'U',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: isPetugas ? AppColors.primaryGreen : const Color(0xFF2B6CB0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'] ?? 'User',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isPetugas
                                        ? const Color(0xFFE8F5E9)
                                        : const Color(0xFFEBF8FF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item['roleLabel'] ?? 'User',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: isPetugas
                                          ? AppColors.primaryGreen
                                          : const Color(0xFF2B6CB0),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isActive ? Colors.green.shade200 : Colors.red.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    isActive ? 'Aktif' : 'Non-Aktif',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Detail List Items
                  _buildDetailRow(
                    icon: Icons.phone_outlined,
                    label: 'Nomor Telepon',
                    value: item['phone'] ?? '-',
                    trailing: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        ResikCallDialog.show(
                          context,
                          officerName: item['name'] ?? 'Pengguna',
                          initialPhone: item['phone'] ?? '',
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.phone_rounded, size: 14, color: AppColors.primaryGreen),
                            SizedBox(width: 4),
                            Text(
                              'Panggil',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                    label: 'Kategori Pengguna',
                    value: item['roleLabel'] ?? 'User',
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow(
                    icon: Icons.location_on_outlined,
                    label: isPetugas ? 'Penugasan' : 'Wilayah / Perumahan',
                    value: item['area'] ?? '-',
                  ),
                  if (item['id_users'] != null) ...[
                    const SizedBox(height: 14),
                    _buildDetailRow(
                      icon: Icons.fingerprint_rounded,
                      label: 'ID Sistem Database',
                      value: '#${item['id_users']}',
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Tombol Aksi: Ubah Keaktifan & Tutup
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _toggleUserActiveStatus(item);
                          },
                          icon: Icon(
                            isActive ? Icons.block_rounded : Icons.check_circle_outline_rounded,
                            size: 18,
                            color: isActive ? AppColors.danger : AppColors.primaryGreen,
                          ),
                          label: Text(
                            isActive ? 'Nonaktifkan Akun' : 'Aktifkan Akun',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isActive ? AppColors.danger : AppColors.primaryGreen,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isActive ? AppColors.danger : AppColors.primaryGreen,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Tutup',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
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
        ...?trailing != null ? [trailing] : null,
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredUsers {
    final query = _searchController.text.trim().toLowerCase();

    return _allUsers.where((u) {
      // Filter kategori: 0: Semua, 1: Petugas, 2: Warga
      if (_selectedCategoryIndex == 1 && u['role'] != 'petugas') return false;
      if (_selectedCategoryIndex == 2 && u['role'] != 'warga') return false;

      if (query.isEmpty) return true;
      return (u['name'] as String).toLowerCase().contains(query) ||
          (u['email'] as String).toLowerCase().contains(query) ||
          (u['phone'] as String).toLowerCase().contains(query) ||
          (u['area'] as String).toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildCategoryTab(int index, String label, int count) {
    final isSelected = _selectedCategoryIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCategoryIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primaryGreen : AppColors.border,
            ),
          ),
          child: Text(
            '$label ($count)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredUsers;
    final petugasCount = _allUsers.where((u) => u['role'] == 'petugas').length;
    final wargaCount = _allUsers.where((u) => u['role'] == 'warga').length;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      // Tombol tambah petugas muncul saat tab Semua atau tab Petugas aktif
      floatingActionButton: (_selectedCategoryIndex == 0 || _selectedCategoryIndex == 1)
          ? FloatingActionButton.extended(
              heroTag: 'fab_tambah_petugas',
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AdminTambahPetugasScreen(),
                  ),
                );
                await _fetchUsers();
              },
              backgroundColor: AppColors.primaryGreen,
              elevation: 3,
              icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
              label: const Text(
                'Tambah Petugas',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchUsers,
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
                          'Data User',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Kelola akun petugas lapangan dan warga perumahan.',
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

                // Kategori Tabs: Semua, Petugas, Warga
                Row(
                  children: [
                    _buildCategoryTab(0, 'Semua', _allUsers.length),
                    const SizedBox(width: 8),
                    _buildCategoryTab(1, 'Petugas', petugasCount),
                    const SizedBox(width: 8),
                    _buildCategoryTab(2, 'Warga', wargaCount),
                  ],
                ),

                const SizedBox(height: 14),

                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: _selectedCategoryIndex == 1
                        ? 'Cari nama/email petugas...'
                        : (_selectedCategoryIndex == 2
                            ? 'Cari nama/email warga...'
                            : 'Cari nama, email, atau nomor HP...'),
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
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
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  )
                else if (list.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        _selectedCategoryIndex == 1
                            ? 'Belum ada data petugas terdaftar.\nKlik tombol Tambah Petugas untuk mendaftarkan.'
                            : (_selectedCategoryIndex == 2
                                ? 'Belum ada data warga terdaftar.'
                                : 'Tidak ada pengguna ditemukan.'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  )
                else
                  // User Cards List
                  ...List.generate(list.length, (idx) {
                    final item = list[idx];
                    final isActive = item['isActive'] as bool;
                    final isPetugas = item['role'] == 'petugas';

                    return InkWell(
                      onTap: () => _showUserDetail(item),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isActive ? AppColors.border : Colors.red.shade100,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: (isPetugas ? AppColors.primaryGreen : const Color(0xFF2B6CB0))
                                  .withValues(alpha: 0.12),
                              child: Text(
                                item['initials'] ?? 'U',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isPetugas ? AppColors.primaryGreen : const Color(0xFF2B6CB0),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['name'] ?? 'User',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isPetugas
                                              ? const Color(0xFFE8F5E9)
                                              : const Color(0xFFEBF8FF),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          item['roleLabel'] ?? 'User',
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w700,
                                            color: isPetugas
                                                ? AppColors.primaryGreen
                                                : const Color(0xFF2B6CB0),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${item['phone']} · ${item['area']}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Switch Aktif/Nonaktif Langsung
                            Tooltip(
                              message: isActive ? 'Klik untuk nonaktifkan' : 'Klik untuk aktifkan',
                              child: InkWell(
                                onTap: () => _toggleUserActiveStatus(item),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isActive ? Colors.green.shade200 : Colors.red.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: isActive ? Colors.green.shade600 : Colors.red.shade600,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isActive ? 'Aktif' : 'Nonaktif',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
