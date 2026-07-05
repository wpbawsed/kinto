import '../models/resource.dart';

/// 展示用假資料。地圖 Pin、搜尋結果與收藏清單在尚未串接
/// `GET /api/v1/resources` 前，先用這份靜態清單顯示畫面（見設計稿 2026-07-04）。
/// TODO: 改為 ApiClient.listResources(lat, lng, radius, types) 的真實資料。
const sampleResources = <Resource>[
  // 座標與 distanceM 皆以地圖預設中心 _kTaipei（台北市政府，見 map_screen.dart）
  // 為基準換算，避免顯示的公尺數與實際座標對不上。
  Resource(
    id: 'sample-toilet-1',
    type: ResourceType.accessibleToilet,
    name: '市政府捷運站 無障礙廁所',
    address: '台北市信義區市府路 1 號',
    phone: '02-2720-8889',
    lat: 25.0406,
    lng: 121.5671,
    distanceM: 480,
    verified: true,
    openHoursText: '每日 06:00 – 22:00',
    isOpenNow: true,
  ),
  Resource(
    id: 'sample-aed-1',
    type: ResourceType.aed,
    name: '台北市政府 1F 大廳 AED',
    address: '台北市信義區市府路 1 號',
    lat: 25.0405,
    lng: 121.5676,
    distanceM: 510,
    verified: true,
    openHoursText: '週一至週五 08:00 – 17:00',
    isOpenNow: true,
  ),
  Resource(
    id: 'sample-ltc-1',
    type: ResourceType.ltcAbc,
    name: '信義區公所 長照關懷據點',
    address: '台北市信義區松德路 12 號',
    lat: 25.0346,
    lng: 121.5693,
    distanceM: 650,
    openHoursText: '週一至週五 09:00 – 18:00',
    isOpenNow: false,
  ),
  // 以下兩筆是跨區的收藏範例（大同區／中正區），距離刻意較遠，
  // distanceM 為與 _kTaipei 的實際換算值（非「附近」語境，僅供收藏頁展示）。
  Resource(
    id: 'sample-ltc-2',
    type: ResourceType.ltcAbc,
    name: '大同區老人服務中心',
    address: '台北市大同區重慶北路二段 171 號',
    lat: 25.0642,
    lng: 121.5127,
    distanceM: 5935,
  ),
  Resource(
    id: 'sample-aed-2',
    type: ResourceType.aed,
    name: '台北車站 1F 大廳 AED',
    address: '台北市中正區北平西路 3 號',
    lat: 25.0478,
    lng: 121.5170,
    distanceM: 4846,
  ),
];

/// 收藏清單目前先取樣本中的固定兩筆（TODO：改接使用者收藏後端）。
const sampleFavoriteIds = <String>['sample-ltc-2', 'sample-aed-2'];
