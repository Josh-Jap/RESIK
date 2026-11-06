import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../services/supabase_service.dart';
import '../widgets/resik_logo.dart';
import '../petugas/petugas_main_screen.dart';
import '../warga/warga_main_screen.dart';
import 'admin_register_screen.dart';
import 'admin_main_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@resik.id');
  final _passwordController = TextEditingController(text: 'admin123');
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _selectedRole = 'Admin'; // 'Admin', 'Petugas', 'Warga'

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
        role: _selectedRole.toLowerCase(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      final role = user?.role?.toLowerCase() ?? _selectedRole.toLowerCase();

      if (role == 'warga') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const WargaMainScreen()),
        );
      } else if (role == 'petugas') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const PetugasMainScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AdminMainScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login gagal: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildRoleTab(String role, String defaultEmail) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = role;
            _emailController.text = defaultEmail;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            role,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
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
                    'Silakan masuk untuk mengelola keasrian dan kebersihan lingkungan rumah Anda.',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Role Selection Chips (Admin, Petugas, Warga)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardSubtle,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _buildRoleTab('Admin', 'admin@resik.id'),
                        _buildRoleTab('Petugas', 'petugas@resik.id'),
                        _buildRoleTab('Warga', 'warga@resik.id'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Email or Username
                  const Text(
                    'Email atau Username',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'nama@email.com atau username',
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
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Email atau username tidak boleh kosong';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Password Field
                  const Text(
                    'Password',
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
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Masukkan password Anda',
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
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
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
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      return null;
                    },
                  ),

                  // Lupa Password?
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fitur reset password telah dikirim ke email admin.'),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Lupa Password?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Masuk Button
                  SizedBox(
                    height: 48,
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
                                strokeWidth: 2,
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

                  const SizedBox(height: 20),

                  // Divider "atau masuk dengan"
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: AppColors.border, thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'atau masuk dengan',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: AppColors.border, thickness: 1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Google Login Button
                  OutlinedButton(
                    onPressed: () {
                      _handleLogin();
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Custom Google 'G' icon
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              'G',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Google',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Footer: Belum punya akun? Daftar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Belum punya akun? ',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AdminRegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Daftar',
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
