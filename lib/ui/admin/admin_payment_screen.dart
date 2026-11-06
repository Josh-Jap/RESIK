import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../backend/backend.dart';
import '../widgets/resik_avatar_badge.dart';

class AdminPaymentScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const AdminPaymentScreen({super.key, this.onNavigateTab});

  @override
  State<AdminPaymentScreen> createState() => _AdminPaymentScreenState();
}

class _AdminPaymentScreenState extends State<AdminPaymentScreen> {
  String _selectedMonth = 'Oktober';
  String _selectedYear = '2026';
  String _selectedStatusFilter = 'Semua';
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _residents = [];
  int _totalIncome = 0;
  int _lunasCount = 0;
  int _belumLunasCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchPaymentData();
  }

  Future<void> _fetchPaymentData() async {
    try {
      final payments = await SupabaseService.instance.getAllPayments();
      final wargaList = await SupabaseService.instance.getUsersByRole('warga');

      final monthPayments = payments.where((p) => p.month == _selectedMonth && p.year == int.tryParse(_selectedYear)).toList();
      final paidMap = <int, PaymentModel>{};
      for (final p in monthPayments) {
        paidMap[p.idUsers] = p;
      }

      final list = <Map<String, dynamic>>[];
      int income = 0;

      for (final w in wargaList) {
        final payment = paidMap[w.idUsers];
        final isPaid = payment != null;
        if (isPaid) income += (payment.amount ?? 50000);

        list.add({
          'initials': w.initials,
          'name': w.nameUsers,
          'date': isPaid ? payment.formattedPaidDate : 'Belum ada pembayaran',
          'amount': isPaid ? payment.formattedAmount : 'Rp50.000',
          'status': isPaid ? 'Lunas' : 'Belum Bayar',
        });
      }

      if (mounted) {
        setState(() {
          _residents.clear();
          _residents.addAll(list);
          _totalIncome = income;
          _lunasCount = paidMap.length;
          _belumLunasCount = wargaList.length - paidMap.length;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredResidents {
    final query = _searchController.text.trim().toLowerCase();
    return _residents.where((r) {
      final matchesQuery = query.isEmpty ||
          (r['name'] as String).toLowerCase().contains(query);
      final matchesStatus = _selectedStatusFilter == 'Semua' ||
          r['status'] == _selectedStatusFilter;
      return matchesQuery && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredResidents;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Laporan Pembayaran',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Pantau pembayaran iuran warga',
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

              const SizedBox(height: 16),

              // Month & Year Selector Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bulan',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedMonth,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tahun',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedYear,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 4 Metric Cards (2x2 Grid)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Total Pemasukan',
                      value: 'Rp${_totalIncome.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                      sub: 'Uang diterima',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.check_circle_outline_rounded,
                      title: 'Sudah Bayar',
                      value: '$_lunasCount warga',
                      sub: 'Iuran sudah lunas',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.people_outline_rounded,
                      title: 'Belum Bayar',
                      value: '$_belumLunasCount warga',
                      sub: 'Iuran belum lunas',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.receipt_long_outlined,
                      title: 'Total Tunggakan',
                      value: 'Rp${(_belumLunasCount * 50000).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                      sub: 'Uang belum dibayar',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const Text(
                'Data contoh · 120 warga · Iuran Rp50.000/bulan',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),

              const SizedBox(height: 18),

              // Section: Riwayat Pembayaran
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Riwayat Pembayaran',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Oktober 2026',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Search Bar
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Cari nama warga',
                  hintStyle: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

              const SizedBox(height: 10),

              // Filter Chips (Semua, Lunas, Belum Bayar)
              Row(
                children: [
                  _buildStatusChip('Semua'),
                  const SizedBox(width: 8),
                  _buildStatusChip('Lunas'),
                  const SizedBox(width: 8),
                  _buildStatusChip('Belum Bayar'),
                ],
              ),

              const SizedBox(height: 12),

              // List of Residents
              ...List.generate(list.length, (idx) {
                final item = list[idx];
                final isLunas = item['status'] == 'Lunas';

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            AppColors.cardSubtle,
                        child: Text(
                          item['initials'],
                          style: const TextStyle(
                            fontSize: 12,
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
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['date'],
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item['amount'],
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isLunas
                                  ? AppColors.badgeSelesaiBg
                                  : AppColors.badgeDiprosesBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item['status'],
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: isLunas
                                    ? AppColors.badgeSelesaiText
                                    : AppColors.badgeDiprosesText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  'Menampilkan 6 dari 120 warga · Data contoh',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Unduh Laporan Button
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Laporan keuangan berhasil diunduh (PDF/Excel)!'),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_rounded, size: 20),
                  label: const Text(
                    'Unduh Laporan Keuangan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label) {
    final isSelected = _selectedStatusFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatusFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
