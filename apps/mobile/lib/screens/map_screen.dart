import 'package:flutter/material.dart';
import '../models/resource.dart';
import '../widgets/filter_chip_row.dart';
import '../theme/app_theme.dart';
import 'search_screen.dart';

/// 地圖主頁（prd §F01 / §4.3）。
///
/// 注意：實際地圖以 google_maps_flutter 的 GoogleMap 元件渲染，
/// 需設定 Google Maps API Key 後才能顯示。此處先放置篩選列與骨架，
/// 待平台原生資料夾（android/ios）由 `flutter create` 產生後接上。
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<ResourceType> _selectedTypes = ResourceType.values.toSet();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('長者友善資源地圖'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          FilterChipRow(
            selected: _selectedTypes,
            onChanged: (next) => setState(() => _selectedTypes = next),
          ),
          const Expanded(
            child: Center(
              // TODO: 換成 GoogleMap(...)，以 GPS 為中心、顯示 ResourcePin
              child: Text('地圖區（待接 google_maps_flutter）'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.report,
        onPressed: () {/* TODO: 緊急撥打 119（prd F07） */},
        child: const Icon(Icons.emergency),
      ),
    );
  }
}
