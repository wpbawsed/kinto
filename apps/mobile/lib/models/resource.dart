import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ResourceType { aed, ltcAbc, accessibleToilet }

/// 距離顯示格式化：< 1000m 顯示公尺，否則顯示公里（1 位小數）。
String formatDistance(int meters) =>
    meters >= 1000 ? '${(meters / 1000).toStringAsFixed(1)} km' : '$meters m';

ResourceType resourceTypeFromApi(String raw) {
  switch (raw) {
    case 'aed':
      return ResourceType.aed;
    case 'ltc_abc':
      return ResourceType.ltcAbc;
    case 'accessible_toilet':
      return ResourceType.accessibleToilet;
    default:
      throw ArgumentError('unknown resource type: $raw');
  }
}

extension ResourceTypeX on ResourceType {
  String get label => switch (this) {
        ResourceType.aed => 'AED',
        ResourceType.ltcAbc => '長照據點',
        ResourceType.accessibleToilet => '無障礙廁所',
      };

  Color get pinColor => switch (this) {
        ResourceType.aed => AppColors.aed,
        ResourceType.ltcAbc => AppColors.ltcAbc,
        ResourceType.accessibleToilet => AppColors.accessibleToilet,
      };

  Color get lightBg => switch (this) {
        ResourceType.aed => AppColors.aedBg,
        ResourceType.ltcAbc => AppColors.ltcAbcBg,
        ResourceType.accessibleToilet => AppColors.toiletBg,
      };

  IconData get icon => switch (this) {
        ResourceType.aed => Icons.medical_services_rounded,
        ResourceType.ltcAbc => Icons.home_rounded,
        ResourceType.accessibleToilet => Icons.accessible_rounded,
      };
}

class Resource {
  final String id;
  final ResourceType type;
  final String name;
  final String? address;
  final String? phone;
  final double? lat;
  final double? lng;
  final int? distanceM;
  final bool verified;

  /// 開放時間顯示文字／目前是否開放中。`open_hours` 目前是後端未定義結構的
  /// JSONB 欄位（見 packages/shared schema），API 尚未提供「是否開放中」的計算結果，
  /// 這兩個欄位僅供畫面展示用的假資料／未來串接使用，不會由 [fromJson] 解析。
  final String? openHoursText;
  final bool? isOpenNow;

  const Resource({
    required this.id,
    required this.type,
    required this.name,
    this.address,
    this.phone,
    this.lat,
    this.lng,
    this.distanceM,
    this.verified = false,
    this.openHoursText,
    this.isOpenNow,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] as String,
      type: resourceTypeFromApi(json['type'] as String),
      name: json['name'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      distanceM: (json['distance_m'] as num?)?.toInt(),
      verified: json['verified'] as bool? ?? false,
    );
  }
}
