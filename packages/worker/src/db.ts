import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import * as schema from "@kinto/shared/schema";

export type Db = ReturnType<typeof drizzle<typeof schema>>;

let _client: ReturnType<typeof postgres> | null = null;
let _db: Db | null = null;

export function getDb(): Db {
  if (_db) return _db;
  const url = process.env.DATABASE_URL;
  if (!url) throw new Error("DATABASE_URL is not set");
  _client = postgres(url);
  _db = drizzle(_client, { schema });
  return _db;
}
