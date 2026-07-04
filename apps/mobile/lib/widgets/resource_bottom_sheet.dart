import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/resource.dart';
import '../theme/app_theme.dart';

/// 資源詳情 Bottom Sheet（prd §F03 / §4.3）。樣式對照 2026-07-04 設計稿：
/// type badge + 已驗證 badge、灰底資訊卡（地址/電話/開放時間）、主次按鈕。
class ResourceBottomSheet extends StatelessWidget {
  final Resource resource;
  final VoidCallback onNavigate;
  final VoidCallback onReport;

  const ResourceBottomSheet({
    super.key,
    required this.resource,
    required this.onNavigate,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 34,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              _TypeBadge(type: resource.type),
              if (resource.verified) ...[
                const SizedBox(width: 9),
                const _VerifiedBadge(),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Text(resource.name, style: AppTextStyles.heroTitle.copyWith(fontSize: 22)),
          if (resource.distanceM != null || resource.address != null) ...[
            const SizedBox(height: 8),
            Text(
              resource.distanceM != null ? '距離約 ${resource.distanceM} 公尺' : resource.address!,
              style: AppTextStyles.helper,
            ),
          ],
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                if (resource.address != null)
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    text: resource.address!,
                    showDivider: resource.phone != null || resource.openHoursText != null,
                    trailing: IconButton(
                      icon: const Icon(Icons.copy_outlined, size: 18),
                      color: AppColors.primaryCta,
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: resource.address!));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('已複製地址')),
                          );
                        }
                      },
                    ),
                  ),
                if (resource.phone != null)
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    text: resource.phone!,
                    showDivider: resource.openHoursText != null,
                    trailing: TextButton(
                      onPressed: () => launchUrl(Uri(scheme: 'tel', path: resource.phone)),
                      child: const Text('撥打', style: TextStyle(color: AppColors.primaryCta, fontWeight: FontWeight.w600)),
                    ),
                  ),
                if (resource.openHoursText != null)
                  _InfoRow(
                    icon: Icons.access_time_rounded,
                    text: resource.openHoursText!,
                    showDivider: false,
                    trailing: resource.isOpenNow == null
                        ? null
                        : _OpenBadge(isOpen: resource.isOpenNow!),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryCta,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.navigation_rounded),
              onPressed: onNavigate,
              label: const Text('導航前往', style: AppTextStyles.button),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.reportBg,
                foregroundColor: AppColors.reportText,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              icon: const Icon(Icons.warning_amber_rounded, size: 19),
              onPressed: onReport,
              label: const Text('回報錯誤', style: AppTextStyles.button),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final ResourceType type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: type.lightBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 11, height: 11, decoration: BoxDecoration(color: type.pinColor, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Text(type.label, style: AppTextStyles.badge.copyWith(color: type.pinColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(color: AppColors.aedBg, borderRadius: BorderRadius.circular(8)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primaryCta),
          SizedBox(width: 5),
          Text('已驗證', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryCta)),
        ],
      ),
    );
  }
}

class _OpenBadge extends StatelessWidget {
  final bool isOpen;
  const _OpenBadge({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOpen ? AppColors.successBg : AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isOpen ? '開放中' : '已打烊',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isOpen ? AppColors.successText : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool showDivider;
  final Widget? trailing;

  const _InfoRow({required this.icon, required this.text, required this.showDivider, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: showDivider
          ? const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border)))
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 21, color: AppColors.textMuted),
          const SizedBox(width: 13),
          Expanded(child: Text(text, style: AppTextStyles.addressPhone.copyWith(fontSize: 16))),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
