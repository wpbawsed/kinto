import {
  pgTable,
  uuid,
  text,
  boolean,
  timestamp,
  jsonb,
  numeric,
  pgEnum,
  uniqueIndex,
} from "drizzle-orm/pg-core";

/** 資源類型（prd §3.3） */
export const resourceTypeEnum = pgEnum("resource_type", [
  "aed",
  "ltc_abc",
  "accessible_toilet",
]);

/** 回報類型（prd §3.3） */
export const reportTypeEnum = pgEnum("report_type", [
  "wrong_location",
  "closed",
  "wrong_info",
]);

/** 資源主表 — AED / 長照據點 / 無障礙廁所 */
export const resources = pgTable(
  "resources",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    type: resourceTypeEnum("type").notNull(),
    name: text("name").notNull(),
    address: text("address"),
    phone: text("phone"),
    // DECIMAL(10,7) — 對應 prd §3.3，以字串保存避免浮點誤差
    lat: numeric("lat", { precision: 10, scale: 7 }),
    lng: numeric("lng", { precision: 10, scale: 7 }),
    openHours: jsonb("open_hours"),
    sourceId: text("source_id"), // 原始 opendata ID（upsert 依據）
    verified: boolean("verified").notNull().default(false),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
  },
  (t) => [
    // 同類型 + 來源 ID 唯一，作為排程 upsert 的衝突鍵
    uniqueIndex("resources_type_source_id_uq").on(t.type, t.sourceId),
  ],
);

/** 用戶回報表 */
export const reports = pgTable("reports", {
  id: uuid("id").primaryKey().defaultRandom(),
  resourceId: uuid("resource_id").references(() => resources.id),
  reportType: reportTypeEnum("report_type").notNull(),
  userLat: numeric("user_lat", { precision: 10, scale: 7 }),
  userLng: numeric("user_lng", { precision: 10, scale: 7 }),
  note: text("note"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
});

export type Resource = typeof resources.$inferSelect;
export type NewResource = typeof resources.$inferInsert;
export type Report = typeof reports.$inferSelect;
export type NewReport = typeof reports.$inferInsert;
