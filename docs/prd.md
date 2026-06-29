# 長者友善資源地圖 — MVP 完整規格文件

> 版本 v0.1 | 2026-06-30 | 狀態：草稿

---

## Part 1｜BRD — 商業需求文件

### 1.1 背景與問題定義

台灣已進入超高齡社會，65 歲以上人口比例持續上升。長者本身、家屬與照顧者在外出時面臨以下痛點：

- 不知道附近哪裡有 AED（官方 app 座標錯誤率高）
- 不知道附近的長照 ABC 據點位置與服務內容
- 無障礙廁所資訊分散在各縣市網站，無整合入口
- 現有政府 app UX 老舊、不友善

### 1.2 商業目標

| 目標 | 指標 | 時程 |
|---|---|---|
| 建立台灣首個整合式長者友善地圖 | DAU 500+ | 上線後 3 個月 |
| 累積用戶資料回報修正 Open Data 錯誤 | 回報筆數 200+ | 上線後 6 個月 |
| 作為公益展示案申請社會創新補助 | 送件 1 件 | 上線後 6 個月 |

### 1.3 目標用戶

**主要用戶（Primary）**
- 照顧者 / 家屬（25–55 歲，幫長輩規劃外出）
- 長者本人（65+，習慣使用手機查詢）

**次要用戶（Secondary）**
- 社工、長照機構工作人員（查詢資源分布）

### 1.4 競品分析摘要

| 競品 | 缺點 |
|---|---|
| 全民急救 AED（衛福部） | 座標錯誤、UX 老舊、無長照資訊 |
| 各縣市社會局網站 | 各自為政，無跨縣市整合，非 App |
| Google Maps | 無長照特有資源（關懷據點、日照中心） |
| Handicap X（德國） | 台灣覆蓋率極低，僅無障礙廁所 |

### 1.5 成功標準

- MVP 上線於 App Store + Google Play
- 整合至少 3 種 Open Data 資料來源
- 支援用戶回報座標錯誤功能
- 應用程式評分 ≥ 4.0

---

## Part 2｜PRD — 產品需求文件

### 2.1 MVP 功能範圍

#### 核心功能（必做）

**F01 — 地圖主頁**
- 以用戶 GPS 位置為中心顯示地圖
- 支援縮放、平移
- 顯示附近資源 Pin（預設半徑 1km）
- Pin 依資源類型以顏色區分

**F02 — 資源類型篩選**
- AED 位置（藍色 Pin）
- 長照 ABC 據點（綠色 Pin）
- 無障礙廁所（紫色 Pin）
- 多選篩選，預設全開

**F03 — 資源詳情頁**
- 場所名稱、地址、電話
- 資源類型 Badge
- 開放時間（若有）
- 「導航前往」按鈕（開啟 Apple Maps / Google Maps）
- 「回報錯誤」入口

**F04 — 搜尋功能**
- 輸入地址或場所名稱
- 支援縣市 + 行政區快速選擇

**F05 — 用戶回報**
- 回報類型：位置錯誤、已停用、資訊有誤
- 附帶用戶當前 GPS 座標作為修正建議
- 送出後顯示感謝訊息

#### 次要功能（MVP 可選）

**F06 — 我的收藏**（選做）
- 收藏常用資源（離線快取）

**F07 — 緊急聯絡**（選做）
- 快速撥打 119 按鈕（固定顯示於地圖角落）

---

### 2.2 使用者流程

```
啟動 App
  ↓
要求 GPS 權限
  ↓
地圖主頁（顯示附近 3 種資源 Pin）
  ↓ [用戶點選 Pin]
資源詳情 Bottom Sheet 滑出
  ↓ [點選「導航」]
跳轉地圖 App
  ↓ [點選「回報錯誤」]
回報表單 → 送出 → 感謝頁
```

---

### 2.3 非功能需求

| 類別 | 需求 |
|---|---|
| 效能 | 地圖載入 < 3 秒（4G 網路） |
| 離線 | 最後一次載入的資料可離線查看 |
| 可及性 | 字體最小 16sp，支援系統字體放大 |
| 語言 | 繁體中文（MVP），英文（後期） |
| 平台 | iOS 15+, Android 10+ |

---

## Part 3｜系統規格

### 3.1 Open Data 資料來源

| 資料 | 來源 URL | 格式 | 更新頻率 |
|---|---|---|---|
| AED 位置 | `https://tw-aed.mohw.gov.tw/openData?t=csv` | CSV | 每日 |
| 長照 ABC 據點 | `https://data.gov.tw/dataset/88270` | JSON | 不定期 |
| 無障礙廁所（新北） | data.gov.tw `dataset/123792` | CSV | 不定期 |
| 長照機構清冊 | 衛福部長照專區 API | JSON | 月更 |

### 3.2 技術架構（MVP）

```
Flutter App (iOS + Android)
  ↓
Backend API (Node.js / Fastify)  ←─ 熟悉的 stack
  ├── GET /resources?lat=&lng=&radius=&types=
  ├── GET /resources/:id
  └── POST /reports
  ↓
PostgreSQL (資源資料 + 用戶回報)

排程任務 (BullMQ)
  ├── 每日拉取 AED CSV → 清洗 → 更新 DB
  └── 每週拉取長照據點 JSON → Upsert
```

### 3.3 資料模型（簡化）

```sql
-- 資源主表
CREATE TABLE resources (
  id          UUID PRIMARY KEY,
  type        ENUM('aed', 'ltc_abc', 'accessible_toilet'),
  name        TEXT NOT NULL,
  address     TEXT,
  phone       TEXT,
  lat         DECIMAL(10, 7),
  lng         DECIMAL(10, 7),
  open_hours  JSONB,
  source_id   TEXT,        -- 原始 opendata ID
  verified    BOOLEAN DEFAULT false,
  updated_at  TIMESTAMP
);

-- 用戶回報表
CREATE TABLE reports (
  id            UUID PRIMARY KEY,
  resource_id   UUID REFERENCES resources(id),
  report_type   ENUM('wrong_location', 'closed', 'wrong_info'),
  user_lat      DECIMAL(10, 7),
  user_lng      DECIMAL(10, 7),
  note          TEXT,
  created_at    TIMESTAMP DEFAULT NOW()
);
```

### 3.4 API 規格（核心端點）

```
GET /api/v1/resources
  Query:
    lat       float  必填  用戶緯度
    lng       float  必填  用戶經度
    radius    int    選填  公尺，預設 1000
    types     string 選填  逗號分隔 e.g. "aed,ltc_abc"
    limit     int    選填  預設 50
  Response:
    { resources: [{ id, type, name, address, lat, lng, distance_m }] }

GET /api/v1/resources/:id
  Response:
    { id, type, name, address, phone, lat, lng, open_hours, verified }

POST /api/v1/reports
  Body:
    { resource_id, report_type, user_lat, user_lng, note? }
  Response:
    { success: true }
```

### 3.5 部署架構

```
Railway (MVP 優先考量，你熟悉)
  ├── fastify-api service
  ├── PostgreSQL plugin
  └── BullMQ worker service (排程拉資料)

CDN: Cloudflare (API 快取, 靜態資源)
```

---

## Part 4｜UI 元素規格

### 4.1 色彩系統

| 用途 | 色碼 | 說明 |
|---|---|---|
| AED Pin | #2196F3 (Blue) | 緊急救援 |
| 長照據點 Pin | #4CAF50 (Green) | 社區照護 |
| 無障礙廁所 Pin | #9C27B0 (Purple) | 設施服務 |
| 主要 CTA | #1976D2 | 導航、確認 |
| 回報錯誤 | #FF5722 | 警示操作 |
| 背景 | #F8F9FA | 卡片、Sheet |

### 4.2 字型規範

| 元素 | 字體大小 | 字重 |
|---|---|---|
| 場所名稱 | 18sp | 600 |
| 地址、電話 | 15sp | 400 |
| Badge 標籤 | 13sp | 500 |
| 輔助說明 | 12sp | 400 |
| 按鈕文字 | 16sp | 500 |

*所有字體需支援系統放大（a11y）*

### 4.3 元件清單

**地圖層**
- MapView（google_maps_flutter）
- ResourcePin（自訂 Marker，含類型圖示）
- RadiusCircle（半透明藍圈）
- MyLocationButton

**篩選層**
- FilterChip Row（AED / 長照據點 / 無障礙廁所）
- 可橫向滾動

**詳情 Bottom Sheet**
- 拖拉把手
- TypeBadge + 場所名稱
- 地址行（含複製按鈕）
- 電話行（可直撥）
- 開放時間折疊區
- 主要按鈕：「導航前往」
- 次要按鈕：「回報錯誤」

**回報 Dialog**
- 回報類型 RadioGroup（3 選 1）
- 備註 TextField（選填）
- 確認 / 取消

**搜尋頁**
- SearchBar（置頂）
- 縣市快捷 ChipRow
- 搜尋結果 ListView

---

## Part 5｜MVP 開發里程碑

| 週次 | 任務 |
|---|---|
| W1–2 | 後端 API + DB schema + 資料爬取 pipeline |
| W3–4 | Flutter 地圖主頁 + Pin 顯示 |
| W5 | 詳情 Bottom Sheet + 導航功能 |
| W6 | 搜尋功能 + 篩選 |
| W7 | 回報功能 |
| W8 | 測試 + Bug Fix + App Store 送審準備 |

---

*文件結束。下一步：Flutter 技術選型確認、Open Data API Key 申請。*