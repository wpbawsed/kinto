import { Queue } from "bullmq";
import IORedis from "ioredis";

export const INGEST_QUEUE = "ingest";

export type IngestJobName = "aed" | "ltc_abc";

export function createConnection(): IORedis {
  const url = process.env.REDIS_URL ?? "redis://localhost:6379";
  return new IORedis(url, { maxRetriesPerRequest: null });
}

export function createIngestQueue(connection: IORedis): Queue {
  return new Queue(INGEST_QUEUE, { connection });
}

/**
 * 註冊週期性排程（prd §3.2）：
 *  - AED：每日 03:00 拉取
 *  - 長照 ABC 據點：每週一 04:00 拉取
 */
export async function registerSchedules(queue: Queue): Promise<void> {
  await queue.upsertJobScheduler(
    "aed-daily",
    { pattern: "0 3 * * *" },
    { name: "aed" satisfies IngestJobName },
  );
  await queue.upsertJobScheduler(
    "ltc-abc-weekly",
    { pattern: "0 4 * * 1" },
    { name: "ltc_abc" satisfies IngestJobName },
  );
}
