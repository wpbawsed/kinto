import 'package:dio/dio.dart';
import '../models/resource.dart';
import '../models/report.dart';

/// 後端 API client（對應 prd §3.4，prefix /api/v1）。
class ApiClient {
  ApiClient({String? baseUrl, Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl ?? const String.fromEnvironment(
                'API_BASE_URL',
                defaultValue: 'http://10.0.2.2:3000/api/v1',
              ),
            ));

  final Dio _dio;

  Future<List<Resource>> listResources({
    required double lat,
    required double lng,
    int radius = 1000,
    List<ResourceType> types = const [],
    int limit = 50,
  }) async {
    final res = await _dio.get('/resources', queryParameters: {
      'lat': lat,
      'lng': lng,
      'radius': radius,
      if (types.isNotEmpty)
        'types': types.map(_typeApiValue).join(','),
      'limit': limit,
    });
    final list = (res.data['resources'] as List)
        .cast<Map<String, dynamic>>()
        .map(Resource.fromJson)
        .toList();
    return list;
  }

  Future<Resource> getResource(String id) async {
    final res = await _dio.get('/resources/$id');
    return Resource.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> submitReport(ReportPayload payload) async {
    await _dio.post('/reports', data: payload.toJson());
  }

  static String _typeApiValue(ResourceType t) => switch (t) {
        ResourceType.aed => 'aed',
        ResourceType.ltcAbc => 'ltc_abc',
        ResourceType.accessibleToilet => 'accessible_toilet',
      };
}
