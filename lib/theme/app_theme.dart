import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Palette: navy blue, light blue, white and subtle neutral backgrounds.
class AppColors {
  AppColors._();

  static const navy = Color(0xFF14285B);
  static const lightBlue = Color(0xFFDCEBFA);
  static const background = Color(0xFFF4F7FB);
  static const border = Color(0xFFE1E8F3);
  static const mutedText = Color(0xFF5B6B84);

  static const success = Color(0xFF2E7D32);
  static const successBg = Color(0xFFE8F5E9);
  static const warning = Color(0xFFB45309);
  static const warningBg = Color(0xFFFFF3E0);
  static const danger = Color(0xFFC62828);
  static const dangerBg = Color(0xFFFDECEA);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.navy).copyWith(
    primary: AppColors.navy,
    onPrimary: Colors.white,
    primaryContainer: AppColors.lightBlue,
    onPrimaryContainer: AppColors.navy,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: AppColors.lightBlue,
      surfaceTintColor: Colors.transparent,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white,
    ),
  );
}

/// Consistent outlined text-field look (kept as a helper instead of a theme
/// entry so it works across Flutter versions).
InputDecoration appInputDecoration(
  String label, {
  Widget? prefixIcon,
  bool alignLabelWithHint = false,
}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: prefixIcon,
    alignLabelWithHint: alignLabelWithHint,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );
}
