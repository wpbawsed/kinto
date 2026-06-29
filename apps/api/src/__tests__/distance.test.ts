import { describe, it, expect } from "vitest";
import { haversineMeters, boundingBox } from "../lib/distance";

describe("haversineMeters", () => {
  it("returns 0 for the same point", () => {
    expect(haversineMeters(25.04, 121.56, 25.04, 121.56)).toBe(0);
  });

  it("approximates Taipei 101 → Taipei Main Station (~4.7km)", () => {
    // Taipei 101 (25.0339, 121.5645) → Taipei Main (25.0478, 121.5170)
    const d = haversineMeters(25.0339, 121.5645, 25.0478, 121.517);
    expect(d).toBeGreaterThan(4000);
    expect(d).toBeLessThan(5500);
  });
});

describe("boundingBox", () => {
  it("produces a box that contains the center", () => {
    const box = boundingBox(25.04, 121.56, 1000);
    expect(box.minLat).toBeLessThan(25.04);
    expect(box.maxLat).toBeGreaterThan(25.04);
    expect(box.minLng).toBeLessThan(121.56);
    expect(box.maxLng).toBeGreaterThan(121.56);
  });

  it("widens longitude span more than latitude near the equator-ish lat", () => {
    const box = boundingBox(25.04, 121.56, 1000);
    const latSpan = box.maxLat - box.minLat;
    const lngSpan = box.maxLng - box.minLng;
    expect(lngSpan).toBeGreaterThan(latSpan);
  });
});
