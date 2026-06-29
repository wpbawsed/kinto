import "dotenv/config";
import { Worker } from "bullmq";
import {
  INGEST_QUEUE,
  createConnection,
  createIngestQueue,
  registerSchedules,
  type IngestJobName,
} from "./queues";
import { runAedIngest } from "./jobs/ingest-aed";
import { runLtcAbcIngest } from "./jobs/ingest-ltc-abc";

async function main(): Promise<void> {
  const connection = createConnection();
  const queue = createIngestQueue(connection);
  await registerSchedules(queue);

  const worker = new Worker(
    INGEST_QUEUE,
    async (job) => {
      const name = job.name as IngestJobName;
      switch (name) {
        case "aed":
          return runAedIngest();
        case "ltc_abc":
          return runLtcAbcIngest();
        default:
          throw new Error(`unknown job: ${job.name}`);
      }
    },
    { connection },
  );

  worker.on("completed", (job, result) => {
    console.log(`[worker] ${job.name} done`, result);
  });
  worker.on("failed", (job, err) => {
    console.error(`[worker] ${job?.name} failed:`, err.message);
  });

  console.log("[worker] ingest worker started");
}

void main();
