import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 送出 · 感謝頁（設計稿 2026-07-04 畫面⑤）。
///
/// [weeklyReportRank] 為「本週第 N 位回報者」，TODO：待後端提供每週回報統計
/// 端點後改為真實數字，目前為展示用預設值。
class ThankYouScreen extends StatelessWidget {
  final int weeklyReportRank;

  const ThankYouScreen({super.key, this.weeklyReportRank = 38});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            const SizedBox(height: 110),
            Container(
              width: 104,
              height: 104,
              decoration: const BoxDecoration(color: AppColors.successBg, shape: BoxShape.circle),
              child: Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.successIcon,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.successIcon.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text('感謝您的回報！', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 44),
              child: Text(
                '我們會盡快查核並更新這筆資料，\n讓更多長輩與照顧者受惠。',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.6),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(18)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$weeklyReportRank', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.primaryCta)),
                  const SizedBox(width: 12),
                  Text('您是本週第 $weeklyReportRank 位\n熱心回報的夥伴', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryCta,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      child: const Text('回到地圖', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('回報紀錄功能開發中')),
                      ),
                      child: const Text('查看我的回報紀錄', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
