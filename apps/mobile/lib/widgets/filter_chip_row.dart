import 'package:flutter/material.dart';
import '../models/resource.dart';
import '../theme/app_theme.dart';

/// 資源類型篩選列（prd §F02 / §4.3）— 多選，預設全開，可橫向滾動。
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: ResourceType.values.map((type) {
          final isOn = selected.contains(type);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(type.label, style: AppTextStyles.badge),
              selected: isOn,
              selectedColor: type.pinColor.withValues(alpha: 0.2),
              onSelected: (on) {
                final next = {...selected};
                if (on) {
                  next.add(type);
                } else {
                  next.remove(type);
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
