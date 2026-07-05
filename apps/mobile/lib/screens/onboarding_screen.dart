import 'package:flutter/material.dart';
import '../models/resource.dart';
import '../theme/app_theme.dart';
import 'map_screen.dart';

/// 啟動 · 定位權限（設計稿 2026-07-04 畫面①）。
///
/// TODO: 目前「允許使用定位」與「先看看地圖」都直接進入地圖頁；
/// 實際定位權限請求（geolocator / permission_handler）待套件選定後串接。
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _enterMap(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MapScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7EDF3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            const SizedBox(height: 100),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primaryCta,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: AppColors.primaryCta.withValues(alpha: 0.35), blurRadius: 28, offset: const Offset(0, 12)),
                ],
              ),
              child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 24),
            const Text('長者友善資源地圖', style: AppTextStyles.heroTitle, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'AED、長照據點、無障礙廁所\n一鍵就近找到',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.5),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [BoxShadow(color: const Color(0xFF00285A).withValues(alpha: 0.12), blurRadius: 30, offset: const Offset(0, 8))],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ResourceType.values
                          .map((t) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  children: [
                                    Container(width: 14, height: 14, decoration: BoxDecoration(color: t.pinColor, shape: BoxShape.circle)),
                                    const SizedBox(height: 6),
                                    Text(t.label, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '開啟定位，顯示您附近的資源',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '我們只在您使用 App 時取得位置，不會儲存或分享您的足跡。',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppColors.textTertiary, height: 1.6),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryCta,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        onPressed: () => _enterMap(context),
                        child: const Text('允許使用定位', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: TextButton(
                        onPressed: () => _enterMap(context),
                        child: const Text('先看看地圖', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
