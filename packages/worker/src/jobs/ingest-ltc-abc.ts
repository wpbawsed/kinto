import { sql } from "drizzle-orm";
import { resources, type NewResource } from "@kinto/shared";
import { getDb } from "../db";
import { stableSourceId } from "../lib/source-id";

const TW_BOUNDS = { minLat: 21.5, maxLat: 25.5, minLng: 119.0, maxLng: 122.5 };

function isValidTwCoord(lat: number, lng: number): boolean {
  return (
    Number.isFinite(lat) &&
    Number.isFinite(lng) &&
    lat >= TW_BOUNDS.minLat &&
    lat <= TW_BOUNDS.maxLat &&
    lng >= TW_BOUNDS.minLng &&
    lng <= TW_BOUNDS.maxLng
  );
}

function pick(obj: Record<string, unknown>, ...keys: string[]): string | null {
  for (const k of keys) {
    const v = obj[k];
    if (typeof v === "string" && v.trim()) return v.trim();
    if (typeof v === "number") return String(v);
  }
  return null;
}

/**
 * 將長照 ABC 據點 JSON（陣列）轉成可 upsert 的 resources。
 * 欄位名稱因來源而異，這裡盡量涵蓋常見命名。
 */
export function parseLtcAbcJson(raw: unknown): NewResource[] {
  const arr = Array.isArray(raw)
    ? raw
    : Array.isArray((raw as { result?: { records?: unknown[] } })?.result?.records)
      ? (raw as { result: { records: unknown[] } }).result.records
      : [];

  const out: NewResource[] = [];
  for (const item of arr) {
    if (typeof item !== "object" || item === null) continue;
    const o = item as Record<string, unknown>;

    const name = pick(o, "機構名稱", "據點名稱", "name", "場所名稱");
    if (!name) continue;
    const latStr = pick(o, "緯度", "lat", "latitude", "y");
    const lngStr = pick(o, "經度", "lng", "lon", "longitude", "x");
    const lat = Number(latStr);
    const lng = Number(lngStr);
    if (!isValidTwCoord(lat, lng)) continue;

    out.push({
      type: "ltc_abc",
      name,
      address: pick(o, "地址", "address"),
      phone: pick(o, "電話", "phone", "tel"),
      lat: String(lat),
      lng: String(lng),
      sourceId: stableSourceId(pick(o, "id", "編號", "機構代碼"), name, lat, lng),
      verified: false,
    });
  }
  return out;
}

/** 拉取長照 ABC 據點 JSON → 清洗 → upsert */
export async function runLtcAbcIngest(
  fetchImpl: typeof fetch = fetch,
): Promise<{ inserted: number }> {
  const url = process.env.LTC_ABC_JSON_URL;
  if (!url) throw new Error("LTC_ABC_JSON_URL is not set");

  const res = await fetchImpl(url);
  if (!res.ok) throw new Error(`LTC fetch failed: ${res.status}`);
  const json: unknown = await res.json();
  const rows = parseLtcAbcJson(json);
  if (rows.length === 0) return { inserted: 0 };

  const db = getDb();
  for (const row of rows) {
    await db
      .insert(resources)
      .values(row)
      .onConflictDoUpdate({
        target: [resources.type, resources.sourceId],
        set: {
          name: row.name,
          address: row.address,
          phone: row.phone,
          lat: row.lat,
          lng: row.lng,
          updatedAt: sql`now()`,
        },
      });
  }
  return { inserted: rows.length };
}
