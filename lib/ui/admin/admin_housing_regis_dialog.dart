import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../backend/backend.dart';

class AdminHousingRegisDialog extends StatefulWidget {
  final Function(HousingModel)? onSaved;
  final bool isMandatory;

  const AdminHousingRegisDialog({
    super.key,
    this.onSaved,
    this.isMandatory = false,
  });

  static Future<HousingModel?> show(
    BuildContext context, {
    Function(HousingModel)? onSaved,
    bool isMandatory = false,
  }) {
    return showModalBottomSheet<HousingModel>(
      context: context,
      isDismissible: !isMandatory,
      enableDrag: !isMandatory,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PopScope(
        canPop: !isMandatory,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AdminHousingRegisDialog(
            onSaved: onSaved,
            isMandatory: isMandatory,
          ),
        ),
      ),
    );
  }

  @override
  State<AdminHousingRegisDialog> createState() => _AdminHousingRegisDialogState();
}

class _AdminHousingRegisDialogState extends State<AdminHousingRegisDialog> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateRandomCode();
  }

  void _generateRandomCode() {
    final rand = Random();
    final code = 100000 + rand.nextInt(900000);
    setState(() {
      _codeController.text = code.toString();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final codeStr = _codeController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama perumahan wajib diisi'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final newHousing = HousingModel(
      nameHouse: name,
      houseCode: int.tryParse(codeStr),
      address: 'Wilayah Griya Asri',
      block: 'A1-Z9',
    );

    try {
      await _supabaseService.addHousing(newHousing);
    } catch (e) {
      debugPrint('Simpan ke Supabase gagal atau offline: $e');
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    widget.onSaved?.call(newHousing);
    Navigator.of(context).pop(newHousing);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Perumahan "$name" berhasil ditambahkan!'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Title & Subtitle
          const Text(
            'Tambah Perumahan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Masukkan data perumahan anda.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 20),

          // Label: Tambah Perumahan
          const Text(
            'Tambah Perumahan',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Masukkan nama perumahan',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
              prefixIcon: const Icon(
                Icons.home_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.border,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryGreen,
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Label: Kode Perumahan
          const Text(
            'Kode Perumahan',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _codeController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Kode Perumahan',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.sync_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                tooltip: 'Acak Kode',
                onPressed: _generateRandomCode,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.border,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryGreen,
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              if (!widget.isMandatory) ...[
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: const BorderSide(
                          color: AppColors.primaryGreen,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.isMandatory ? 'Simpan & Daftarkan Perumahan' : 'Simpan',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
