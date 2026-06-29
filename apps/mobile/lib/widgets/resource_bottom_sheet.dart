import 'package:flutter/material.dart';
import '../models/resource.dart';
import '../theme/app_theme.dart';

/// 資源詳情 Bottom Sheet（prd §F03 / §4.3）。
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          _TypeBadge(type: resource.type),
          const SizedBox(height: 8),
          Text(resource.name, style: AppTextStyles.placeName),
          if (resource.address != null) ...[
            const SizedBox(height: 8),
            Text(resource.address!, style: AppTextStyles.addressPhone),
          ],
          if (resource.phone != null) ...[
            const SizedBox(height: 4),
            Text(resource.phone!, style: AppTextStyles.addressPhone),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primaryCta),
              onPressed: onNavigate,
              child: const Text('導航前往', style: AppTextStyles.button),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.report),
              onPressed: onReport,
              child: const Text('回報錯誤', style: AppTextStyles.button),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: type.pinColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.label,
        style: AppTextStyles.badge.copyWith(color: type.pinColor),
      ),
    );
  }
}
