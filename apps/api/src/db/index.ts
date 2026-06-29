import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import * as schema from "@kinto/shared/schema";

export type Db = ReturnType<typeof drizzle<typeof schema>>;

let _client: ReturnType<typeof postgres> | null = null;
let _db: Db | null = null;

/**
 * 延遲建立連線：只有在第一次需要 DB 的請求時才連線，
 * 讓不碰 DB 的測試（如 /api/health）無需啟動 postgres。
 */
export function getDb(): Db {
  if (_db) return _db;
  const url = process.env.DATABASE_URL;
  if (!url) {
    throw new Error("DATABASE_URL is not set");
  }
  _client = postgres(url);
  _db = drizzle(_client, { schema });
  return _db;
}

export async function closeDb(): Promise<void> {
  if (_client) {
    await _client.end();
    _client = null;
    _db = null;
  }
}
