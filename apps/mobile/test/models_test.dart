import 'package:flutter_test/flutter_test.dart';
import 'package:kinto_mobile/models/resource.dart';
import 'package:kinto_mobile/models/report.dart';

void main() {
  group('Resource.fromJson', () {
    test('maps api type strings to enum', () {
      final r = Resource.fromJson({
        'id': '1',
        'type': 'ltc_abc',
        'name': '據點',
        'address': '台北市',
        'lat': 25.0,
        'lng': 121.0,
        'distance_m': 120,
      });
      expect(r.type, ResourceType.ltcAbc);
      expect(r.distanceM, 120);
    });

    test('throws on unknown type', () {
      expect(
        () => Resource.fromJson({'id': '1', 'type': 'bogus', 'name': 'x'}),
        throwsArgumentError,
      );
    });
  });

  group('ReportPayload.toJson', () {
    test('uses api snake_case values and omits empty note', () {
      final json = const ReportPayload(
        resourceId: 'r1',
        reportType: ReportType.wrongLocation,
        userLat: 25.0,
        userLng: 121.0,
      ).toJson();
      expect(json['report_type'], 'wrong_location');
      expect(json.containsKey('note'), false);
    });
  });
}
