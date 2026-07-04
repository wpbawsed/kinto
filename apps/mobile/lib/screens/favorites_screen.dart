import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/sample_resources.dart';
import '../models/resource.dart';
import '../theme/app_theme.dart';
import '../utils/navigation_launcher.dart';

/// 我的收藏（prd §F06，設計稿 2026-07-04）。
/// TODO: 目前用 [sampleResources] + [sampleFavoriteIds] 假資料，
/// 待收藏功能後端（收藏清單 + 離線快取）確定後改為真實資料來源。
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = sampleResources.where((r) => sampleFavoriteIds.contains(r.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), offset: const Offset(0, 1))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('我的收藏', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  TextButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('編輯功能開發中')),
                    ),
                    child: const Text('編輯', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryCta)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(14)),
                    child: const Row(
                      children: [
                        Icon(Icons.cloud_done_outlined, size: 18, color: AppColors.successIcon),
                        SizedBox(width: 10),
                        Text('已離線快取，沒有網路也能查看', style: TextStyle(fontSize: 13, color: AppColors.successText, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  if (favorites.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(child: Text('尚未收藏任何資源', style: AppTextStyles.helper)),
                    )
                  else
                    ...favorites.map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _FavoriteCard(resource: r),
                        )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Resource resource;
  const _FavoriteCard({required this.resource});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 3, offset: const Offset(0, 1))],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: resource.type.lightBg, borderRadius: BorderRadius.circular(13)),
                child: Icon(resource.type.icon, color: resource.type.pinColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(resource.name, style: AppTextStyles.placeName.copyWith(fontSize: 17)),
                    const SizedBox(height: 3),
                    Text(
                      [
                        if (resource.address != null) resource.address!,
                        if (resource.distanceM != null) _formatDistance(resource.distanceM!),
                      ].join(' · '),
                      style: AppTextStyles.caption.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.favorite_rounded, color: Color(0xFFE53935), size: 24),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryCta,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                    ),
                    icon: const Icon(Icons.navigation_rounded, size: 17),
                    onPressed: () => launchNavigationTo(resource),
                    label: const Text('導航', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 44,
                height: 44,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.background,
                    foregroundColor: AppColors.textSecondary,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                    elevation: 0,
                  ),
                  onPressed: resource.phone == null
                      ? null
                      : () => launchUrl(Uri(scheme: 'tel', path: resource.phone)),
                  child: const Icon(Icons.phone_outlined, size: 19),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDistance(int meters) => meters >= 1000 ? '${(meters / 1000).toStringAsFixed(1)} km' : '$meters m';
}
