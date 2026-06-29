# 長者友善資源地圖（kinto）— Mono-repo 初始化規劃書

> 對應規格：`docs/prd.md`（BRD / PRD / 系統規格 / UI / 里程碑）
> 目標：建立 Flutter App + Fastify API + BullMQ 排程 + PostgreSQL 的開發骨架，可本地一鍵啟動、可部署至 Railway。

---

## 技術決策

| 項目             | 選擇                                       | 說明                                                  |
| ---------------- | ------------------------------------------ | ----------------------------------------------------- |
| 後端 Mono-repo   | pnpm workspaces                            | 管理 `api` / `worker` / `shared`，Flutter App 獨立其外 |
| Node.js 版本     | >= 22                                      | `.nvmrc` + `engines` 欄位統一鎖定                     |
| 行動端           | Flutter（Dart）                            | iOS 15+ / Android 10+，單一程式碼雙平台               |
| 地圖元件         | google_maps_flutter                        | 對應 prd §4.3 地圖層                                  |
| 後端框架         | Fastify（Node.js）                         | prd §3.2 指定，團隊熟悉                               |
| 資料驗證         | Zod                                        | API request/response schema 驗證                     |
| ORM              | Drizzle ORM + postgres.js 驅動             | 型別安全；由 schema 產生 SQL migration               |
| DB Migration     | drizzle-kit generate + migrate             | SQL 檔案納入版控                                      |
| 資料庫           | PostgreSQL 16                              | 資源資料 + 用戶回報                                   |
| 排程 / Queue     | BullMQ + Redis                             | prd §3.2 每日 AED / 每週長照據點拉取                  |
| 共用套件         | packages/shared（直接引用 TS 原始碼）      | DB schema、型別、Zod 由 api 與 worker 共用           |
| 測試框架         | Vitest（api / worker）、flutter test（app）| —                                                     |
| 容器化（本地）   | docker-compose，含 healthcheck             | postgres + redis，解決啟動 race condition            |
| 部署             | Railway（api + worker + PG + Redis）        | prd §3.5；CDN 走 Cloudflare                           |

---

## 目錄結構

```
kinto/
├── apps/
│   ├── api/                      # Fastify + Drizzle ORM + Zod（REST API）
│   │   ├── src/
│   │   │   ├── db/
│   │   │   │   ├── migrations/   # drizzle-kit 產生的 SQL，納入版控
│   │   │   │   └── index.ts      # postgres.js + Drizzle client
│   │   │   ├── routes/
│   │   │   │   ├── resources.ts  # GET /resources, GET /resources/:id
│   │   │   │   └── reports.ts    # POST /reports
│   │   │   ├── plugins/          # fastify plugins（db、cors、env）
│   │   │   ├── lib/              # 距離計算、geo 查詢工具
│   │   │   ├── __tests__/
│   │   │   └── index.ts          # Fastify app 入口
│   │   ├── Dockerfile
│   │   ├── .dockerignore
│   │   ├── drizzle.config.ts
│   │   ├── vitest.config.ts
│   │   ├── tsconfig.json
│   │   └── package.json
│   └── mobile/                   # Flutter App（iOS + Android）
│       ├── lib/
│       │   ├── main.dart
│       │   ├── models/           # Resource / Report 資料模型
│       │   ├── services/         # API client（dio / http）
│       │   ├── screens/          # 地圖主頁、詳情、搜尋、回報
│       │   ├── widgets/          # ResourcePin、FilterChip、BottomSheet
│       │   └── theme/            # 色彩 / 字型（對應 prd §4.1 / §4.2）
│       ├── test/
│       ├── android/
│       ├── ios/
│       └── pubspec.yaml
├── packages/
│   ├── worker/                   # BullMQ 排程 worker（Open Data 拉取）
│   │   ├── src/
│   │   │   ├── jobs/
│   │   │   │   ├── ingest-aed.ts        # 每日：AED CSV → 清洗 → upsert
│   │   │   │   └── ingest-ltc-abc.ts    # 每週：長照據點 JSON → upsert
│   │   │   ├── queues.ts         # BullMQ queue / scheduler 定義
│   │   │   ├── __tests__/
│   │   │   └── index.ts          # worker 入口
│   │   ├── Dockerfile
│   │   ├── .dockerignore
│   │   ├── vitest.config.ts
│   │   ├── tsconfig.json
│   │   └── package.json
│   └── shared/                   # 共享 DB schema / 型別 / Zod（直接引用 TS 原始碼）
│       ├── src/
│       │   ├── schema/
│       │   │   └── index.ts      # Drizzle table：resources, reports
│       │   ├── dto/
│       │   │   └── index.ts      # Zod schema：API request/response
│       │   └── index.ts
│       ├── tsconfig.json
│       └── package.json
├── .gitignore
├── .nvmrc                        # 內容：22
├── .env.example                 # 本地開發環境變數範本
├── .env.docker.example          # Docker 環境變數範本
├── docker-compose.yml            # postgres + redis（本地）
├── package.json                  # pnpm 根工作區
├── pnpm-workspace.yaml
└── tsconfig.base.json
```

> **Flutter App 不納入 pnpm workspace**：`pnpm-workspace.yaml` 只宣告 `apps/api`、`packages/*`；`apps/mobile` 由 Flutter / Dart toolchain 獨立管理。

---

## Phase 1 — Root 基礎設定

1. 建立根 `package.json`（`name: kinto`，`private: true`，`engines: { node: ">=22" }`，scripts: `dev` / `build` / `test` / `typecheck`）
2. 建立 `pnpm-workspace.yaml`，宣告 `apps/api` 與 `packages/*`
3. 建立 `tsconfig.base.json`（`strict`, `ESNext`, `bundler` module resolution）
4. 建立 `.gitignore`（排除 `node_modules`, `dist`, `.env`, Flutter 的 `build/` / `.dart_tool/`；保留 `db/migrations`）
5. 建立 `.nvmrc`（內容：`22`）
6. 建立 `.env.example`：
   ```env
   DATABASE_URL=postgres://user:pass@localhost:5432/kinto
   REDIS_URL=redis://localhost:6379
   PORT=3000
   # Open Data 來源（prd §3.1）
   AED_CSV_URL=https://tw-aed.mohw.gov.tw/openData?t=csv
   LTC_ABC_JSON_URL=https://data.gov.tw/dataset/88270
   ```
7. 根層安裝 dev 依賴：`typescript`、`concurrently`

---

## Phase 2 — packages/shared（DB schema + 型別 + Zod）

8. 建立 `packages/shared/package.json`：
   ```json
   {
     "name": "@kinto/shared",
     "exports": {
       ".": { "types": "./src/index.ts", "default": "./src/index.ts" }
     }
   }
   ```
   > **策略：直接引用 TS 原始碼**，tsx / Vitest 皆可直接解析，修改立即生效、無需 rebuild。
9. 建立 `packages/shared/tsconfig.json`（`extends ../../tsconfig.base.json`）
10. 安裝依賴：`drizzle-orm`、`zod`
11. 建立 `src/schema/index.ts`（Drizzle table，對應 prd §3.3）：
    - `resources`：`id`(uuid pk)、`type`(enum: `aed` / `ltc_abc` / `accessible_toilet`)、`name`、`address`、`phone`、`lat`/`lng`(decimal 10,7)、`open_hours`(jsonb)、`source_id`、`verified`(bool default false)、`updated_at`
    - `reports`：`id`(uuid pk)、`resource_id`(fk → resources)、`report_type`(enum: `wrong_location` / `closed` / `wrong_info`)、`user_lat`/`user_lng`、`note`、`created_at`(default now)
12. 建立 `src/dto/index.ts`（Zod schema：`resources` 查詢參數、`POST /reports` body 等，對應 prd §3.4）
13. 建立 `src/index.ts`（彙整 export schema 與 dto）

---

## Phase 3 — apps/api（Fastify 後端）

14. 建立 `apps/api/package.json`（`engines: { node: ">=22" }`，scripts: `dev` / `build` / `db:generate` / `db:migrate` / `test` / `typecheck`）
15. 安裝依賴：
    ```
    fastify  @fastify/cors  drizzle-orm  postgres  zod  @kinto/shared
    ```
16. 安裝 dev 依賴：
    ```
    drizzle-kit  tsx  @types/node  dotenv  vitest
    ```
17. 建立 `apps/api/tsconfig.json`（`extends ../../tsconfig.base.json`，`target: ES2022`）
18. 建立 `apps/api/vitest.config.ts`（`environment: node`，透過 dotenv 載入 `.env`）
19. 建立 `apps/api/drizzle.config.ts`（schema 指向 `@kinto/shared` 的 `src/schema`，migrations 輸出至 `src/db/migrations`）
20. 建立 `src/db/index.ts`（初始化 postgres.js + Drizzle client，讀取 `DATABASE_URL`）
21. 建立 `src/index.ts`（Fastify app 入口，`GET /api/health` 回 200，掛載 cors、db plugin）
22. 建立路由（對應 prd §3.4，prefix `/api/v1`）：
    - `src/routes/resources.ts`：
      - `GET /resources?lat=&lng=&radius=&types=&limit=` — 依距離回傳附近資源（含 `distance_m`）
      - `GET /resources/:id` — 單筆詳情
    - `src/routes/reports.ts`：
      - `POST /reports` — 建立用戶回報，回 `{ success: true }`
23. 建立 `src/lib/`（Haversine 距離計算、半徑過濾工具）
24. 建立 `src/__tests__/`，含 health 與 resources 路由範例測試

---

## Phase 4 — packages/worker（BullMQ 排程）

25. 建立 `packages/worker/package.json`（scripts: `dev` / `build` / `test` / `typecheck`）
26. 安裝依賴：
    ```
    bullmq  ioredis  postgres  drizzle-orm  @kinto/shared
    ```
27. 安裝 dev 依賴：`tsx`、`@types/node`、`dotenv`、`vitest`
28. 建立 `src/queues.ts`（定義 queue 與 repeatable job：AED 每日、長照據點每週）
29. 建立 `src/jobs/ingest-aed.ts`（拉 AED CSV → 解析 → 清洗座標 → upsert `resources`，`type='aed'`）
30. 建立 `src/jobs/ingest-ltc-abc.ts`（拉長照 ABC JSON → upsert `resources`，`type='ltc_abc'`）
31. 建立 `src/index.ts`（啟動 BullMQ worker，連線 `REDIS_URL`）
32. 建立 `src/__tests__/`（清洗 / upsert 邏輯單元測試，外部 HTTP 以 mock 取代）

---

## Phase 5 — apps/mobile（Flutter App）

33. 使用 `flutter create apps/mobile`（org 設定 `tw.kinto`）建立專案骨架
34. `pubspec.yaml` 加入依賴：
    ```
    google_maps_flutter  geolocator  dio  flutter_riverpod  url_launcher
    ```
35. 建立 `lib/theme/`（色彩與字型，對應 prd §4.1 / §4.2，字體支援系統放大 a11y）
36. 建立 `lib/models/`（`Resource`、`Report`）與 `lib/services/api_client.dart`（指向後端 `/api/v1`）
37. 建立畫面骨架（對應 prd §2.1 / §4.3）：
    - `screens/map_screen.dart`（地圖主頁 + ResourcePin + RadiusCircle + MyLocationButton）
    - `widgets/filter_chip_row.dart`（AED / 長照據點 / 無障礙廁所 多選）
    - `widgets/resource_bottom_sheet.dart`（詳情 + 導航 + 回報入口）
    - `screens/search_screen.dart`、`widgets/report_dialog.dart`
38. iOS / Android 設定定位權限（Info.plist / AndroidManifest）與 Google Maps API Key
39. 建立 `test/`，含 widget 範例測試

---

## Phase 6 — Docker 容器化（本地開發）

### 40. `docker-compose.yml` 關鍵設定（postgres + redis）

```yaml
services:
  postgres:
    image: postgres:16-alpine
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 5s
      timeout: 5s
      retries: 5
    volumes:
      - pgdata:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 5s
      retries: 5

  api:
    depends_on:
      postgres:
        condition: service_healthy   # 等 postgres 就緒，解決 race condition
    env_file: .env.docker
    ports:
      - "3000:3000"
    # CMD 先執行 db:migrate 再啟動 server

  worker:
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    env_file: .env.docker

volumes:
  pgdata:
```

### 41. `apps/api/Dockerfile` / `packages/worker/Dockerfile`

Multi-stage build：`node:22-alpine` 建置 → `node:22-alpine` runtime。

### 42. `.env.docker.example`

```env
POSTGRES_USER=kinto
POSTGRES_PASSWORD=changeme
POSTGRES_DB=kinto

# 注意：主機名為 docker-compose service 名稱，非 localhost
DATABASE_URL=postgres://kinto:changeme@postgres:5432/kinto
REDIS_URL=redis://redis:6379
```

### 43. `.dockerignore`（各服務）

```
node_modules
dist
.env
```

---

## Phase 7 — 部署（Railway + Cloudflare，對應 prd §3.5）

44. Railway 專案建立三個 service：`api`（Fastify）、`worker`（BullMQ）、PostgreSQL plugin、Redis plugin
45. 設定環境變數（`DATABASE_URL`、`REDIS_URL`、Open Data URLs）由 Railway 變數注入
46. `api` 部署流程：build → `db:migrate` → 啟動
47. Cloudflare：API 快取 / 靜態資源 CDN（prd §3.5）

---

## Phase 8 — 開發串連

48. 根 `package.json` scripts：
    ```json
    {
      "dev": "concurrently \"pnpm --filter @kinto/api dev\" \"pnpm --filter @kinto/worker dev\"",
      "test": "pnpm -r test",
      "typecheck": "pnpm -r typecheck"
    }
    ```
    > Flutter App 以 `cd apps/mobile && flutter run` 單獨啟動。

---

## 關鍵套件版本（2026 Q1）

| 套件                   | 版本    |
| ---------------------- | ------- |
| fastify                | ^5.x    |
| @fastify/cors          | ^10.x   |
| drizzle-orm            | ^0.40.x |
| drizzle-kit            | ^0.30.x |
| postgres (postgres.js) | ^3.x    |
| zod                    | ^3.x    |
| bullmq                 | ^5.x    |
| ioredis                | ^5.x    |
| vitest                 | ^3.x    |
| Node.js                | >= 22   |
| Flutter                | ^3.x（stable） |
| google_maps_flutter    | ^2.x    |
| geolocator             | ^13.x   |
| dio                    | ^5.x    |

---

## Verification Checklist

- [ ] `pnpm install` 根目錄無錯誤
- [ ] `docker compose up postgres redis` → 兩者 healthcheck 通過
- [ ] `pnpm --filter @kinto/api db:generate` → 由 shared schema 產生 SQL migration
- [ ] `pnpm --filter @kinto/api db:migrate` → `resources` / `reports` table 建立成功
- [ ] `pnpm --filter @kinto/api dev` → Fastify 在 3000 啟動，`GET /api/health` 回 200
- [ ] `GET /api/v1/resources?lat=25.04&lng=121.56` → 回傳含 `distance_m` 的資源清單
- [ ] `POST /api/v1/reports` → 寫入回報，回 `{ success: true }`
- [ ] `pnpm --filter @kinto/worker dev` → 連上 Redis，repeatable job 註冊成功
- [ ] worker job 手動觸發 → AED / 長照據點資料 upsert 進 `resources`
- [ ] `pnpm -r test` → api / worker 所有 vitest 通過
- [ ] `cd apps/mobile && flutter run` → 地圖主頁載入，定位權限請求正常
- [ ] App 呼叫後端 `/api/v1/resources` → 地圖顯示對應類型 Pin（藍/綠/紫）
- [ ] 點選 Pin → 詳情 Bottom Sheet 滑出，「導航」「回報」可運作
