import 'package:flutter/material.dart';

/// 色彩系統（prd §4.1，2026-07-04 視覺改版擴充淺色背景 / 文字 / 邊框色階）
class AppColors {
  static const aed = Color(0xFF2196F3); // AED Pin
  static const ltcAbc = Color(0xFF4CAF50); // 長照據點 Pin
  static const accessibleToilet = Color(0xFF9C27B0); // 無障礙廁所 Pin
  static const primaryCta = Color(0xFF1976D2); // 主要 CTA
  static const report = Color(0xFFFF5722); // 回報錯誤
  static const emergency = Color(0xFFD32F2F); // 119 緊急撥號
  static const background = Color(0xFFF8F9FA); // 卡片 / Sheet 背景
  static const screenBg = Color(0xFFF4F7FA); // 全螢幕頁面背景（回報／搜尋／收藏）

  // 淺色底（type badge / 統計卡）
  static const aedBg = Color(0xFFE3F2FD);
  static const ltcAbcBg = Color(0xFFE8F5E9);
  static const toiletBg = Color(0xFFF3E5F5);

  // 成功／已驗證／開放中
  static const successIcon = Color(0xFF43A047);
  static const successText = Color(0xFF2E7D32);
  static const successBg = Color(0xFFE8F5E9);

  // 回報錯誤（次要按鈕淺色版）
  static const reportBg = Color(0xFFFBE9E7);
  static const reportText = Color(0xFFE64A19);

  // 文字色階
  static const textPrimary = Color(0xFF1A2733);
  static const textBody = Color(0xFF33424F);
  static const textIcon = Color(0xFF41505E);
  static const textSecondary = Color(0xFF5A7184);
  static const textTertiary = Color(0xFF7A8B9A);
  static const textMuted = Color(0xFF90A2B2);

  // 邊框／分隔線
  static const border = Color(0xFFE6ECF1);
  static const borderStrong = Color(0xFFC9D4DE);
}

/// 字型規範（prd §4.2）— 全部支援系統放大（a11y）
class AppTextStyles {
  static const heroTitle = TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: AppColors.textPrimary);
  static const screenTitle = TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const sectionTitle = TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const placeName = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const addressPhone = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textBody);
  static const badge = TextStyle(fontSize: 13, fontWeight: FontWeight.w500);
  static const caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textTertiary);
  static const button = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  static const helper = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.primaryCta,
    scaffoldBackgroundColor: AppColors.background,
  );
}
