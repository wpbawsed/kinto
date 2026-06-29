/**
 * 產生穩定且非空的 source_id 作為 upsert 去重鍵。
 *
 * Postgres 唯一索引中 NULL 互不相等，若 source_id 為 NULL，
 * onConflictDoUpdate 永遠不會命中 → 每次排程都重複插入同一筆資源。
 * 因此來源未提供 ID 時，以 name + 座標合成穩定鍵（同一實體每次結果相同）。
 */
export function stableSourceId(
  provided: string | null | undefined,
  name: string,
  lat: number | string,
  lng: number | string,
): string {
  const trimmed = provided?.trim();
  if (trimmed) return trimmed;
  return `gen:${name.trim()}|${lat}|${lng}`;
}
