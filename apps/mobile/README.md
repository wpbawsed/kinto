# kinto_mobile — 長者友善資源地圖 App

Flutter App（iOS + Android）。本骨架由 `personal-developer-agent` 手動建立（環境未安裝 Flutter），尚未產生平台原生資料夾。

## 啟用步驟（需先安裝 Flutter SDK）

```bash
cd apps/mobile
# 1. 產生 android/ ios/ 平台資料夾（保留現有 lib/ test/ pubspec.yaml）
flutter create . --org tw.kinto --project-name kinto_mobile
# 2. 安裝依賴
flutter pub get
# 3. 測試
flutter test
# 4. 執行（API_BASE_URL 預設指向 Android 模擬器的 10.0.2.2:3000）
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```

## 待補（TODO）

- 接上 `google_maps_flutter` 的 `GoogleMap`（需設定 Google Maps API Key）
- iOS `Info.plist` / Android `AndroidManifest.xml` 定位權限與 Maps Key
- `geolocator` 取得 GPS、繪製 `ResourcePin` 與半徑圈
- 詳情頁「導航前往」以 `url_launcher` 開啟 Apple/Google Maps
- 緊急撥打 119（prd F07）

## 對應規格

| 檔案 | prd |
|---|---|
| `lib/theme/app_theme.dart` | §4.1 色彩、§4.2 字型 |
| `lib/screens/map_screen.dart` | F01 地圖主頁 |
| `lib/widgets/filter_chip_row.dart` | F02 篩選 |
| `lib/widgets/resource_bottom_sheet.dart` | F03 詳情 |
| `lib/screens/search_screen.dart` | F04 搜尋 |
| `lib/widgets/report_dialog.dart` | F05 回報 |
| `lib/services/api_client.dart` | §3.4 API |
