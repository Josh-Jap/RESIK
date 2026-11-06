import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../backend/backend.dart';
import '../widgets/resik_logo.dart';
import '../petugas/petugas_main_screen.dart';
import '../warga/warga_main_screen.dart';
import '../warga/warga_register_screen.dart';
import 'admin_main_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await SupabaseService.instance.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      final role = (user?.role ?? 'warga').toLowerCase();

      if (role == 'admin') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AdminMainScreen()),
        );
      } else if (role == 'petugas') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const PetugasMainScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const WargaMainScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),

                  // RESIK Logo
                  const Center(
                    child: ResikLogo(
                      isDarkBackground: false,
                      iconSize: 64,
                      titleSize: 22,
                      subtitleSize: 9.5,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Welcome Header
                  const Text(
                    'Selamat Datang Kembali',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Silakan masukkan email dan kata sandi Anda untuk mengakses akun RESIK.',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Email Input
                  const Text(
                    'Email Akun',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'nama@resik.id atau email Anda',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
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

                  const SizedBox(height: 18),

                  // Kata Sandi
                  const Text(
                    'Kata Sandi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Kata sandi tidak boleh kosong';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Masukkan kata sandi',
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
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
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

                  // Button Masuk
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
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
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Masuk',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Footer: Belum punya akun? Daftar sebagai Warga
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Belum punya akun warga? ',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const WargaRegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Daftar Warga',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
