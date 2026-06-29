import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ResourceType { aed, ltcAbc, accessibleToilet }

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

  const Resource({
    required this.id,
    required this.type,
    required this.name,
    this.address,
    this.phone,
    this.lat,
    this.lng,
    this.distanceM,
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
    );
  }
}
