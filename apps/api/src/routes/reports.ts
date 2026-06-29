import type { FastifyPluginAsync } from "fastify";
import { createReportBodySchema, reports } from "@kinto/shared";
import { getDb } from "../db/index";

export const reportsRoutes: FastifyPluginAsync = async (app) => {
  // POST /reports
  app.post("/reports", async (req, reply) => {
    const parsed = createReportBodySchema.safeParse(req.body);
    if (!parsed.success) {
      return reply.status(400).send({ error: parsed.error.flatten() });
    }
    const body = parsed.data;
    const db = getDb();
    await db.insert(reports).values({
      resourceId: body.resource_id,
      reportType: body.report_type,
      userLat: String(body.user_lat),
      userLng: String(body.user_lng),
      note: body.note,
    });
    return reply.status(201).send({ success: true });
  });
};
