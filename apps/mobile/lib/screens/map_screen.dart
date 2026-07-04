import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/sample_resources.dart';
import '../models/resource.dart';
import '../theme/app_theme.dart';
import '../utils/navigation_launcher.dart';
import '../widgets/filter_chip_row.dart';
import '../widgets/resource_bottom_sheet.dart';
import 'favorites_screen.dart';
import 'report_screen.dart';
import 'search_screen.dart';

// 台北市政府一帶，與設計稿「市政府捷運站」場景及 sampleResources 群聚位置一致。
const _kTaipei = LatLng(25.0375, 121.5637);

/// 地圖主頁（prd §F01 / §4.3，設計稿 2026-07-04 畫面②）：
/// 浮動搜尋列＋篩選 chip、119 緊急撥號、定位按鈕、底部可拖曳資源統計面板。
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<ResourceType> _selectedTypes = ResourceType.values.toSet();
  final _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  List<Resource> get _visibleResources =>
      sampleResources.where((r) => _selectedTypes.contains(r.type)).toList();

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

  Future<void> _confirmEmergencyCall() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('撥打 119'),
        content: const Text('確定要撥打 119 緊急救援專線嗎？'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.emergency),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('撥打'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await launchUrl(Uri(scheme: 'tel', path: '119'));
    }
  }

  void _recenterOnMe() {
    // TODO: 待接 geolocator 取得使用者實際 GPS 座標後改為真實定位，
    // 目前先固定回到台北市中心作為展示。
    _mapController.move(_kTaipei, 15);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleResources;
    final counts = {for (final t in ResourceType.values) t: visible.where((r) => r.type == t).length};

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _kTaipei,
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.kinto.app',
              ),
              CircleLayer(circles: [
                CircleMarker(
                  point: _kTaipei,
                  radius: 250,
                  useRadiusInMeter: true,
                  color: AppColors.primaryCta.withValues(alpha: 0.1),
                  borderColor: AppColors.primaryCta.withValues(alpha: 0.4),
                  borderStrokeWidth: 1.5,
                ),
              ]),
              MarkerLayer(markers: [
                Marker(
                  point: _kTaipei,
                  width: 22,
                  height: 22,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryCta,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [BoxShadow(color: AppColors.primaryCta.withValues(alpha: 0.5), blurRadius: 6)],
                    ),
                  ),
                ),
                for (final r in visible)
                  if (r.lat != null && r.lng != null)
                    Marker(
                      point: LatLng(r.lat!, r.lng!),
                      width: 44,
                      height: 44,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () => _openDetail(r),
                        child: _ResourcePin(type: r.type),
                      ),
                    ),
              ]),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: const Color(0xFF00285A).withValues(alpha: 0.12), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.menu_rounded, color: AppColors.textIcon),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchScreen())),
                            child: const Text('搜尋地點、地址', style: TextStyle(fontSize: 17, color: AppColors.textIcon, fontWeight: FontWeight.w500)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FavoritesScreen())),
                          child: const Icon(Icons.favorite_border_rounded, color: AppColors.textIcon),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(color: AppColors.primaryCta, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: const Text('長', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilterChipRow(
                      selected: _selectedTypes,
                      onChanged: (next) => setState(() => _selectedTypes = next),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 18,
            bottom: 210,
            child: GestureDetector(
              onTap: _confirmEmergencyCall,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.emergency,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppColors.emergency.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('119', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white, height: 1)),
                    SizedBox(height: 2),
                    Text('緊急', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 18,
            bottom: 214,
            child: GestureDetector(
              onTap: _recenterOnMe,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryCta,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: AppColors.primaryCta.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: const Icon(Icons.my_location_rounded, color: Colors.white),
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.24,
            minChildSize: 0.16,
            maxChildSize: 0.55,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -4))],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                  children: [
                    Center(
                      child: Container(
                        width: 34,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(color: AppColors.borderStrong, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('附近 ${visible.length} 處資源', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const Text('大同區 · 1 km', style: TextStyle(fontSize: 14, color: AppColors.textTertiary, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: ResourceType.values.map((t) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              decoration: BoxDecoration(color: t.lightBg, borderRadius: BorderRadius.circular(16)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${counts[t]}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: t.pinColor, height: 1)),
                                  const SizedBox(height: 3),
                                  Text(t.label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ResourcePin extends StatelessWidget {
  final ResourceType type;
  const _ResourcePin({required this.type});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.785398, // -45deg：與設計稿的水滴狀 Pin 一致
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: type.pinColor,
          border: Border.all(color: Colors.white, width: 2.5),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(21),
            topRight: Radius.circular(21),
            bottomLeft: Radius.circular(21),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.28), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Transform.rotate(
          angle: 0.785398,
          child: Icon(type.icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
