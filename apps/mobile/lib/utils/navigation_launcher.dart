import 'package:url_launcher/url_launcher.dart';
import '../models/resource.dart';

/// 開啟 Apple Maps / Google Maps 導航（prd §F03「導航前往」）。
/// 使用通用的 Google Maps web URL，各平台會交給已安裝的地圖 App 開啟。
Future<void> launchNavigationTo(Resource resource) async {
  final query = resource.lat != null && resource.lng != null
      ? '${resource.lat},${resource.lng}'
      : Uri.encodeComponent(resource.address ?? resource.name);
  final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
