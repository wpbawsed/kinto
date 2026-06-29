import Fastify, { type FastifyInstance } from "fastify";
import cors from "@fastify/cors";
import { resourcesRoutes } from "./routes/resources";
import { reportsRoutes } from "./routes/reports";

export async function buildApp(): Promise<FastifyInstance> {
  const app = Fastify({ logger: true });

  await app.register(cors, { origin: true });

  app.get("/api/health", async () => ({ status: "ok" }));

  await app.register(resourcesRoutes, { prefix: "/api/v1" });
  await app.register(reportsRoutes, { prefix: "/api/v1" });

  return app;
}
