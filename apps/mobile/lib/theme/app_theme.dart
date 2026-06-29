import 'package:flutter/material.dart';

/// 色彩系統（prd §4.1）
class AppColors {
  static const aed = Color(0xFF2196F3); // AED Pin
  static const ltcAbc = Color(0xFF4CAF50); // 長照據點 Pin
  static const accessibleToilet = Color(0xFF9C27B0); // 無障礙廁所 Pin
  static const primaryCta = Color(0xFF1976D2); // 主要 CTA
  static const report = Color(0xFFFF5722); // 回報錯誤
  static const background = Color(0xFFF8F9FA); // 卡片 / Sheet 背景
}

/// 字型規範（prd §4.2）— 全部支援系統放大（a11y）
class AppTextStyles {
  static const placeName = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const addressPhone = TextStyle(fontSize: 15, fontWeight: FontWeight.w400);
  static const badge = TextStyle(fontSize: 13, fontWeight: FontWeight.w500);
  static const caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
  static const button = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.primaryCta,
    scaffoldBackgroundColor: AppColors.background,
  );
}
