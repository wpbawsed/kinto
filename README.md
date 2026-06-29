# kinto — 長者友善資源地圖

整合台灣 AED、長照 ABC 據點、無障礙廁所的長者友善地圖。規格見 [`docs/prd.md`](docs/prd.md)、初始化規劃見 [`docs/INITIALIZATION_PLAN.md`](docs/INITIALIZATION_PLAN.md)。

## 結構

| 路徑 | 說明 |
|---|---|
| `apps/api` | Fastify REST API（`/api/v1/resources`、`/reports`） |
| `apps/mobile` | Flutter App（iOS + Android）|
| `packages/worker` | BullMQ 排程（拉取 Open Data）|
| `packages/shared` | 共享 Drizzle schema / Zod DTO |

## 本地開發

```bash
pnpm install
cp .env.example .env
cp .env.docker.example .env.docker

# 啟動 postgres + redis
docker compose up -d postgres redis

# 產生並套用 migration
pnpm --filter @kinto/api db:generate
pnpm --filter @kinto/api db:migrate

# 啟動後端（api + worker）
pnpm dev

# 測試 / 型別檢查
pnpm -r test
pnpm -r typecheck
```

Flutter App 啟用見 [`apps/mobile/README.md`](apps/mobile/README.md)。
