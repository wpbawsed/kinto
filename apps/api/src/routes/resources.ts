import type { FastifyPluginAsync } from "fastify";
import { and, gte, lte, inArray, eq } from "drizzle-orm";
import {
  listResourcesQuerySchema,
  resourceIdParamSchema,
  resources,
  type ResourceListItem,
} from "@kinto/shared";
import { getDb } from "../db/index";
import { haversineMeters, boundingBox } from "../lib/distance";

export const resourcesRoutes: FastifyPluginAsync = async (app) => {
  // GET /resources?lat=&lng=&radius=&types=&limit=
  app.get("/resources", async (req, reply) => {
    const parsed = listResourcesQuerySchema.safeParse(req.query);
    if (!parsed.success) {
      return reply.status(400).send({ error: parsed.error.flatten() });
    }
    const { lat, lng, radius, types, limit } = parsed.data;
    const box = boundingBox(lat, lng, radius);

    const db = getDb();
    const conditions = [
      gte(resources.lat, String(box.minLat)),
      lte(resources.lat, String(box.maxLat)),
      gte(resources.lng, String(box.minLng)),
      lte(resources.lng, String(box.maxLng)),
    ];
    if (types && types.length > 0) {
      conditions.push(inArray(resources.type, types));
    }

    const rows = await db
      .select()
      .from(resources)
      .where(and(...conditions));

    const items: ResourceListItem[] = rows
      .map((r) => {
        const rLat = r.lat == null ? null : Number(r.lat);
        const rLng = r.lng == null ? null : Number(r.lng);
        const distance =
          rLat == null || rLng == null
            ? Number.POSITIVE_INFINITY
            : haversineMeters(lat, lng, rLat, rLng);
        return {
          id: r.id,
          type: r.type,
          name: r.name,
          address: r.address,
          lat: rLat,
          lng: rLng,
          distance_m: Math.round(distance),
        };
      })
      .filter((r) => r.distance_m <= radius)
      .sort((a, b) => a.distance_m - b.distance_m)
      .slice(0, limit);

    return { resources: items };
  });

  // GET /resources/:id
  app.get("/resources/:id", async (req, reply) => {
    const parsed = resourceIdParamSchema.safeParse(req.params);
    if (!parsed.success) {
      return reply.status(400).send({ error: parsed.error.flatten() });
    }
    const db = getDb();
    const [row] = await db
      .select()
      .from(resources)
      .where(eq(resources.id, parsed.data.id))
      .limit(1);

    if (!row) {
      return reply.status(404).send({ error: "resource not found" });
    }
    return {
      id: row.id,
      type: row.type,
      name: row.name,
      address: row.address,
      phone: row.phone,
      lat: row.lat == null ? null : Number(row.lat),
      lng: row.lng == null ? null : Number(row.lng),
      open_hours: row.openHours,
      verified: row.verified,
    };
  });
};
