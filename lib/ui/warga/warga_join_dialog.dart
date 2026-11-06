import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../backend/backend.dart';

class WargaJoinDialog extends StatefulWidget {
  final Function(String)? onJoined;
  final bool isMandatory;

  const WargaJoinDialog({
    super.key,
    this.onJoined,
    this.isMandatory = false,
  });

  static Future<String?> show(
    BuildContext context, {
    Function(String)? onJoined,
    bool isMandatory = false,
  }) {
    return showModalBottomSheet<String>(
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
          child: WargaJoinDialog(
            onJoined: onJoined,
            isMandatory: isMandatory,
          ),
        ),
      ),
    );
  }

  @override
  State<WargaJoinDialog> createState() => _WargaJoinDialogState();
}

class _WargaJoinDialogState extends State<WargaJoinDialog> {
  final _codeController = TextEditingController(text: 'GAP-RESIK-10');
  String? _suggestedInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAvailableHousing();
  }

  Future<void> _checkAvailableHousing() async {
    try {
      final list = await SupabaseService.instance.getAllHousing();
      if (list.isNotEmpty && mounted) {
        final latest = list.last;
        final code = latest.houseCode?.toString() ?? 'GAP-RESIK-10';
        setState(() {
          _suggestedInfo = '${latest.nameHouse} (Kode: $code)';
          _codeController.text = code;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleJoin() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode perumahan wajib diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = SupabaseService.instance.currentUser;
    final userId = user?.idUsers ?? 5;
    final success = await SupabaseService.instance.joinHousingForUser(userId, code);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      widget.onJoined?.call(code);
      Navigator.of(context).pop(code);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil bergabung ke Perumahan (Kode: $code)!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode perumahan tidak ditemukan atau gagal bergabung'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBg, // #F5F3EA
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
            'Join Perumahan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary, // #252A27
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Masukkan kode perumahan untuk bergabung dan mulai mengawasi kebersihan di perumahan tempat tinggal Anda.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary, // #7FA68C
              height: 1.35,
            ),
          ),

          const SizedBox(height: 20),

          // Input field: Kode Perumahan
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
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.cardBg, // #FFFFFF
              hintText: 'Masukkan kode perumahan',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
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
                  color: AppColors.border, // #D9DDD7
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryGreen, // #245C4A
                  width: 1.5,
                ),
              ),
            ),
          ),

          if (_suggestedInfo != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Perumahan terdaftar: $_suggestedInfo',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Action Buttons: Batal & Gabung
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
                    onPressed: _isLoading ? null : _handleJoin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen, // #245C4A
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
                            widget.isMandatory ? 'Gabung & Lanjutkan' : 'Gabung',
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
