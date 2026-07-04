import 'package:flutter/material.dart';
import '../data/sample_resources.dart';
import '../models/resource.dart';
import '../theme/app_theme.dart';
import '../utils/navigation_launcher.dart';
import '../widgets/resource_bottom_sheet.dart';
import 'report_screen.dart';

/// 搜尋頁（prd §F04 / §4.3，設計稿 2026-07-04）：SearchBar + 縣市快捷 + 結果清單。
/// TODO: 目前用 [sampleResources] 做前端關鍵字比對，待接 GET /api/v1/resources
/// 的縣市／關鍵字搜尋參數後改為真實資料。
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _cities = ['台北市', '新北市', '桃園市', '台中市'];

  final _controller = TextEditingController(text: '市政府');
  String _city = '台北市';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Resource> get _results {
    final q = _controller.text.trim();
    if (q.isEmpty) return sampleResources;
    return sampleResources.where((r) {
      return r.name.contains(q) || (r.address?.contains(q) ?? false);
    }).toList();
  }

  void _openDetail(Resource resource) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => ResourceBottomSheet(
        resource: resource,
        onNavigate: () => launchNavigationTo(resource),
        onReport: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReportScreen(resource: resource)));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), offset: const Offset(0, 1))],
              ),
              child: Column(
                children: [
                  Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primaryCta, width: 2),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: AppColors.primaryCta.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: AppColors.primaryCta, size: 22),
                        const SizedBox(width: 11),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(border: InputBorder.none, hintText: '輸入地址或場所名稱', isDense: true),
                            style: const TextStyle(fontSize: 18, color: AppColors.textPrimary),
                          ),
                        ),
                        if (_controller.text.isNotEmpty)
                          GestureDetector(
                            onTap: () => setState(() => _controller.clear()),
                            child: const Icon(Icons.close_rounded, size: 16, color: Colors.white)
                                .withCircleBg(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _cities
                          .map((c) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _CityChip(
                                  label: c,
                                  selected: c == _city,
                                  onTap: () => setState(() => _city = c),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Text('搜尋結果 · ${results.length} 筆', style: const TextStyle(fontSize: 14, color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  ...results.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ResultCard(resource: r, onTap: () => _openDetail(r)),
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

class _CityChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CityChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryCta : Colors.white,
            borderRadius: BorderRadius.circular(19),
            border: selected ? null : Border.all(color: AppColors.borderStrong.withValues(alpha: 0.8), width: 1.5),
          ),
          child: Text(label, style: TextStyle(fontSize: 15, fontWeight: selected ? FontWeight.w600 : FontWeight.w500, color: selected ? Colors.white : AppColors.textIcon)),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Resource resource;
  final VoidCallback onTap;

  const _ResultCard({required this.resource, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 3, offset: const Offset(0, 1))],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: resource.type.lightBg, borderRadius: BorderRadius.circular(13)),
                child: Icon(resource.type.icon, color: resource.type.pinColor, size: 20),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(resource.name, style: AppTextStyles.placeName.copyWith(fontSize: 17)),
                    const SizedBox(height: 3),
                    Text(
                      [
                        if (resource.address != null) resource.address!,
                        if (resource.distanceM != null) '${resource.distanceM} m',
                      ].join(' · '),
                      style: AppTextStyles.caption.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.borderStrong),
            ],
          ),
        ),
      ),
    );
  }
}

extension _CircleBg on Widget {
  Widget withCircleBg() => Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(color: AppColors.borderStrong, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: this,
      );
}
