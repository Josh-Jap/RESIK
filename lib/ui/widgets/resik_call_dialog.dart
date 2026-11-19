import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

class ResikCallDialog extends StatefulWidget {
  final String officerName;
  final String initialPhone;

  const ResikCallDialog({
    super.key,
    required this.officerName,
    required this.initialPhone,
  });

  static Future<void> show(
    BuildContext context, {
    required String officerName,
    required String initialPhone,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ResikCallDialog(
        officerName: officerName,
        initialPhone: initialPhone,
      ),
    );
  }

  @override
  State<ResikCallDialog> createState() => _ResikCallDialogState();
}

class _ResikCallDialogState extends State<ResikCallDialog> {
  late String _phoneNumber;

  @override
  void initState() {
    super.initState();
    _phoneNumber = widget.initialPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (_phoneNumber.isEmpty) {
      _phoneNumber = '081234567890';
    }
  }

  void _onKeyPress(String digit) {
    if (_phoneNumber.length < 15) {
      setState(() {
        _phoneNumber += digit;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _onBackspace() {
    if (_phoneNumber.isNotEmpty) {
      setState(() {
        _phoneNumber = _phoneNumber.substring(0, _phoneNumber.length - 1);
      });
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _makeDirectCall() async {
    if (_phoneNumber.isEmpty) return;
    final Uri callUri = Uri(scheme: 'tel', path: _phoneNumber);
    try {
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        await launchUrl(callUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka dialer telepon: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.phone_in_talk_rounded,
                      color: AppColors.primaryGreen,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Panggil Petugas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        widget.officerName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 22),
                color: AppColors.textMuted,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Display Nomor Telepon (Screen Papan Nomor)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.cardSubtle,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    _phoneNumber.isEmpty ? 'Masukkan nomor...' : _phoneNumber,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _phoneNumber.isEmpty ? AppColors.textMuted : AppColors.textPrimary,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                if (_phoneNumber.isNotEmpty)
                  GestureDetector(
                    onTap: _onBackspace,
                    onLongPress: () => setState(() => _phoneNumber = ''),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.backspace_outlined,
                        color: AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Papan Nomor (Dial Pad 3x4)
          Column(
            children: [
              _buildDialRow(['1', '2', '3']),
              const SizedBox(height: 10),
              _buildDialRow(['4', '5', '6']),
              const SizedBox(height: 10),
              _buildDialRow(['7', '8', '9']),
              const SizedBox(height: 10),
              _buildDialRow(['*', '0', '#']),
            ],
          ),

          const SizedBox(height: 20),

          // Tombol Panggil Hijau Besar (Call Button)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _phoneNumber.isEmpty ? null : _makeDirectCall,
              icon: const Icon(Icons.phone_rounded, color: Colors.white, size: 22),
              label: const Text(
                'Panggil Sekarang',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) => _buildDialButton(key)).toList(),
    );
  }

  Widget _buildDialButton(String text) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeyPress(text),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 62,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8F6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
