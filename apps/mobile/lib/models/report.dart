enum ReportType { wrongLocation, closed, wrongInfo }

extension ReportTypeX on ReportType {
  String get apiValue => switch (this) {
        ReportType.wrongLocation => 'wrong_location',
        ReportType.closed => 'closed',
        ReportType.wrongInfo => 'wrong_info',
      };

  String get label => switch (this) {
        ReportType.wrongLocation => '位置錯誤',
        ReportType.closed => '已停用',
        ReportType.wrongInfo => '資訊有誤',
      };
}

class ReportPayload {
  final String resourceId;
  final ReportType reportType;
  final double userLat;
  final double userLng;
  final String? note;

  const ReportPayload({
    required this.resourceId,
    required this.reportType,
    required this.userLat,
    required this.userLng,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'resource_id': resourceId,
        'report_type': reportType.apiValue,
        'user_lat': userLat,
        'user_lng': userLng,
        if (note != null && note!.isNotEmpty) 'note': note,
      };
}
