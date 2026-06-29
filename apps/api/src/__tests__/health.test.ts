import { describe, it, expect, afterAll, beforeAll } from "vitest";
import type { FastifyInstance } from "fastify";
import { buildApp } from "../app";

let app: FastifyInstance;

beforeAll(async () => {
  app = await buildApp();
  await app.ready();
});

afterAll(async () => {
  await app.close();
});

describe("GET /api/health", () => {
  it("returns 200 with status ok", async () => {
    const res = await app.inject({ method: "GET", url: "/api/health" });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toEqual({ status: "ok" });
  });
});

describe("POST /api/v1/reports validation", () => {
  it("returns 400 on invalid body (no DB needed)", async () => {
    const res = await app.inject({
      method: "POST",
      url: "/api/v1/reports",
      payload: { resource_id: "not-a-uuid" },
    });
    expect(res.statusCode).toBe(400);
  });
});

describe("GET /api/v1/resources validation", () => {
  it("returns 400 when lat/lng missing (no DB needed)", async () => {
    const res = await app.inject({ method: "GET", url: "/api/v1/resources" });
    expect(res.statusCode).toBe(400);
  });
});
