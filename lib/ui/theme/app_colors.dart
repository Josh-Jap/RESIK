import 'package:flutter/material.dart';

/// RESIK Design System Color Palette
/// Exactly configured from the provided Figma specifications
class AppColors {
  // Primary Brand Colors
  static const Color primaryGreen = Color(0xFF245C4A); // #245C4A - Primary Brand Green
  static const Color primaryDark = Color(0xFF245C4A);  // #245C4A - Splash & Primary Dark
  static const Color primaryMuted = Color(0xFF7FA68C); // #7FA68C - Muted Sage Green
  static const Color accentMint = Color(0xFF83EBAB);   // #83EBAB - Eco Leaf & Glowing Status

  // Backgrounds & Surfaces
  static const Color scaffoldBg = Color(0xFFF5F3EA);   // #F5F3EA - Warm Cream Scaffold Background
  static const Color cardBg = Color(0xFFFFFFFF);       // #FFFFFF - Pure White Surface
  static const Color inputBg = Color(0xFFFFFFFF);      // #FFFFFF - Pure White Inputs
  static const Color cardSubtle = Color(0xFFECEAE0);   // Subtle tinted cream for avatars/chips

  // Borders & Dividers
  static const Color border = Color(0xFFD9DDD7);       // #D9DDD7 - Border Color
  static const Color borderLight = Color(0xFFE6EAE4);

  // Typography
  static const Color textPrimary = Color(0xFF252A27);  // #252A27 - Dark Charcoal Primary Text
  static const Color textSecondary = Color(0xFF7FA68C);// #7FA68C - Muted Sage Text
  static const Color textMuted = Color(0xFF9AA7A0);
  static const Color textLight = Color(0xFFC5D9CD);

  // Status Badges & Accents
  // Baru (New) - Coral Red
  static const Color badgeBaruBg = Color(0xFFFDE8E8);   // Soft red tint
  static const Color badgeBaruText = Color(0xFFC75C5C); // #C75C5C - Coral Red

  // Diproses (In Progress) - Amber / Warm Yellow
  static const Color badgeDiprosesBg = Color(0xFFFFF4D8); // #FFF4D8 - Warm Cream / Amber tint
  static const Color badgeDiprosesText = Color(0xFFD69E2E); // #D69E2E - Amber Gold

  // Selesai (Completed) - Eco Green
  static const Color badgeSelesaiBg = Color(0xFFE4F7EC);
  static const Color badgeSelesaiText = Color(0xFF245C4A); // #245C4A - Deep Green

  // Destructive / Logout Action
  static const Color danger = Color(0xFFC75C5C);       // #C75C5C - Danger Red
}
