import 'package:flutter/material.dart';
import '../models/resource.dart';
import '../theme/app_theme.dart';

/// 資源類型篩選列（prd §F02 / §4.3）— 多選，預設全開，可橫向滾動。
/// 樣式對照 2026-07-04 設計稿：選中為藍底白字＋勾選 icon，未選為白底邊框。
class FilterChipRow extends StatelessWidget {
  final Set<ResourceType> selected;
  final ValueChanged<Set<ResourceType>> onChanged;

  const FilterChipRow({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: ResourceType.values.map((type) {
          final isOn = selected.contains(type);
          return Padding(
            padding: const EdgeInsets.only(right: 9),
            child: _FilterPill(
              type: type,
              isOn: isOn,
              onTap: () {
                final next = {...selected};
                if (isOn) {
                  next.remove(type);
                } else {
                  next.add(type);
                }
                onChanged(next);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final ResourceType type;
  final bool isOn;
  final VoidCallback onTap;

  const _FilterPill({required this.type, required this.isOn, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: isOn ? AppColors.primaryCta : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isOn ? null : Border.all(color: AppColors.borderStrong, width: 1.5),
            boxShadow: isOn
                ? [BoxShadow(color: AppColors.primaryCta.withValues(alpha: 0.3), blurRadius: 5, offset: const Offset(0, 2))]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isOn)
                const Padding(
                  padding: EdgeInsets.only(right: 7),
                  child: Icon(Icons.check_rounded, size: 16, color: Colors.white),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(color: type.pinColor, shape: BoxShape.circle),
                  ),
                ),
              Text(
                type.label,
                style: AppTextStyles.badge.copyWith(
                  fontSize: 15,
                  color: isOn ? Colors.white : AppColors.textIcon,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
