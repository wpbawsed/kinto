import { sql } from "drizzle-orm";
import { resources, type NewResource } from "@kinto/shared";
import { getDb } from "../db";
import { stableSourceId } from "../lib/source-id";

/** 台灣概略經緯度範圍，用於過濾明顯錯誤座標（prd §1.1 座標錯誤率高） */
const TW_BOUNDS = { minLat: 21.5, maxLat: 25.5, minLng: 119.0, maxLng: 122.5 };

/** 解析單行 CSV（處理雙引號包覆的欄位） */
export function splitCsvLine(line: string): string[] {
  const out: string[] = [];
  let cur = "";
  let inQuotes = false;
  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (ch === '"') {
      if (inQuotes && line[i + 1] === '"') {
        cur += '"';
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (ch === "," && !inQuotes) {
      out.push(cur);
      cur = "";
    } else {
      cur += ch;
    }
  }
  out.push(cur);
  return out.map((s) => s.trim());
}

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

/**
 * 將 AED Open Data CSV 轉成可 upsert 的 resources。
 * 預期欄位（不分大小寫）：id/編號、name/場所名稱、address/地址、
 * phone/電話、lat/緯度、lng/經度。座標不合法者剔除。
 */
export function parseAedCsv(csv: string): NewResource[] {
  const lines = csv.split(/\r?\n/).filter((l) => l.trim().length > 0);
  if (lines.length < 2) return [];

  const header = splitCsvLine(lines[0]!).map((h) => h.toLowerCase());
  const idx = (...names: string[]) =>
    header.findIndex((h) => names.some((n) => h.includes(n)));

  const iId = idx("id", "編號");
  const iName = idx("name", "名稱", "場所");
  const iAddr = idx("address", "地址");
  const iPhone = idx("phone", "電話");
  const iLat = idx("lat", "緯度");
  const iLng = idx("lng", "lon", "經度");

  const out: NewResource[] = [];
  for (let r = 1; r < lines.length; r++) {
    const cols = splitCsvLine(lines[r]!);
    const lat = Number(cols[iLat]);
    const lng = Number(cols[iLng]);
    if (!isValidTwCoord(lat, lng)) continue;
    const name = (cols[iName] ?? "").trim();
    if (!name) continue;

    out.push({
      type: "aed",
      name,
      address: cols[iAddr]?.trim() || null,
      phone: cols[iPhone]?.trim() || null,
      lat: String(lat),
      lng: String(lng),
      sourceId: stableSourceId(cols[iId], name, lat, lng),
      verified: false,
    });
  }
  return out;
}

/** 拉取 AED CSV → 清洗 → upsert（以 source_id 為衝突鍵） */
export async function runAedIngest(
  fetchImpl: typeof fetch = fetch,
): Promise<{ inserted: number }> {
  const url = process.env.AED_CSV_URL;
  if (!url) throw new Error("AED_CSV_URL is not set");

  const res = await fetchImpl(url);
  if (!res.ok) throw new Error(`AED fetch failed: ${res.status}`);
  const csv = await res.text();
  const rows = parseAedCsv(csv);
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
