import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../admin/admin_login_screen.dart';
import '../../backend/backend.dart';
import 'warga_join_dialog.dart';

class WargaProfilScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const WargaProfilScreen({super.key, this.onNavigateTab});

  @override
  State<WargaProfilScreen> createState() => _WargaProfilScreenState();
}

class _WargaProfilScreenState extends State<WargaProfilScreen> {
  String _name = 'Warga';
  String _email = '-';
  String _phone = '-';
  String _housingName = 'Belum Bergabung';
  String _housingCode = '-';
  String _housingAddress = '-';

  bool _notifLaporanBaru = true;
  final _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = SupabaseService.instance.currentUser;
    if (user != null) {
      _name = user.nameUsers.isNotEmpty ? user.nameUsers : 'Warga';
      _email = user.email ?? '-';
      _phone = user.displayPhone;
    }
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    var user = SupabaseService.instance.currentUser;
    if (user != null && user.housing == null && user.idHouse != null) {
      final h = await SupabaseService.instance.getHousingById(user.idHouse!);
      if (h != null) {
        user = user.copyWith(housing: h);
        SupabaseService.instance.setCurrentUser(user);
      }
    }
    if (user != null && mounted) {
      setState(() {
        _name = user!.nameUsers.isNotEmpty
            ? user.nameUsers
            : (user.email?.split('@').first ?? 'Warga');
        _email = user.email ?? '-';
        _phone = user.displayPhone;
        if (user.housing != null) {
          _housingName = user.housing!.nameHouse;
          _housingCode = user.housing!.houseCode != null
              ? user.housing!.houseCode.toString()
              : (user.housing!.nameHouse.isNotEmpty ? user.housing!.nameHouse : '-');
          _housingAddress = user.housing!.address ?? 'Wilayah Perumahan';
        } else {
          _housingName = 'Belum Bergabung';
          _housingCode = '-';
          _housingAddress = '-';
        }
      });
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    super.dispose();
  }

  void _showEditDialog(String title, String currentValue, Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ubah $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Masukkan $title baru',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onSave(controller.text.trim());
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Keluar dari Akun',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Apakah Anda ingin keluar dari akun Warga?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await SupabaseService.instance.logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger, // #C75C5C
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg, // #F5F3EA
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Profile Card (Dark Green #245C4A)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen, // #245C4A
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E6F5B),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2),
                      ),
                      child: Center(
                        child: Text(
                          _name.trim().isNotEmpty
                              ? (_name.trim().split(' ').length > 1
                                  ? '${_name.trim().split(' ')[0][0]}${_name.trim().split(' ')[1][0]}'.toUpperCase()
                                  : _name.trim()[0].toUpperCase())
                              : 'W',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'WARGA PERUMAHAN',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: AppColors.accentMint, // #83EBAB
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
              ),

              const SizedBox(height: 20),

              // SECTION 1: INFO AKUN
              _buildSectionCard(
                title: 'INFO AKUN',
                children: [
                  _buildInfoRow(
                    label: 'Nama Lengkap',
                    value: _name,
                    showEdit: true,
                    onEdit: () => _showEditDialog('Nama Lengkap', _name, (val) => setState(() => _name = val)),
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  _buildInfoRow(
                    label: 'Email',
                    value: _email,
                    showEdit: true,
                    onEdit: () => _showEditDialog('Email', _email, (val) => setState(() => _email = val)),
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  _buildInfoRow(
                    label: 'Nomor Telepon',
                    value: _phone,
                    showEdit: false,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // SECTION 2: INFO PERUMAHAN
              _buildSectionCard(
                title: 'INFO PERUMAHAN',
                children: [
                  _buildInfoRow(
                    label: 'Perumahan',
                    value: _housingName,
                    showEdit: true,
                    onEdit: () async {
                      final res = await showModalBottomSheet<String>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const WargaJoinDialog(),
                      );
                      if (res != null) {
                        _loadProfileData();
                      }
                    },
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  _buildInfoRow(
                    label: 'Kode Perumahan',
                    value: _housingCode,
                    showEdit: false,
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  _buildInfoRow(
                    label: 'Alamat',
                    value: _housingAddress,
                    showEdit: false,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // SECTION 3: PENGATURAN NOTIFIKASI
              _buildSectionCard(
                title: 'PENGATURAN NOTIFIKASI',
                children: [
                  _buildSwitchRow(
                    label: 'Laporan Baru',
                    value: _notifLaporanBaru,
                    onChanged: (val) => setState(() => _notifLaporanBaru = val),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // SECTION 4: KEAMANAN (UBAH PASSWORD)
              _buildSectionCard(
                title: 'KEAMANAN (UBAH PASSWORD)',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Password Lama',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.cardSubtle,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Text(
                            '••••••••',
                            style: TextStyle(
                              letterSpacing: 2,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Password Baru',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _newPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Masukkan password baru',
                            hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Button: Keluar dari Akun
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger, // #C75C5C
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Keluar dari Akun',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required bool showEdit,
    VoidCallback? onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
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
          if (showEdit)
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.primaryGreen,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
