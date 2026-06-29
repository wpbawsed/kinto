import { describe, it, expect } from "vitest";
import {
  listResourcesQuerySchema,
  createReportBodySchema,
} from "./index";

describe("listResourcesQuerySchema", () => {
  it("coerces string query params and applies defaults", () => {
    const parsed = listResourcesQuerySchema.parse({ lat: "25.04", lng: "121.56" });
    expect(parsed.lat).toBe(25.04);
    expect(parsed.lng).toBe(121.56);
    expect(parsed.radius).toBe(1000);
    expect(parsed.limit).toBe(50);
    expect(parsed.types).toBeUndefined();
  });

  it("splits comma-separated types into a validated array", () => {
    const parsed = listResourcesQuerySchema.parse({
      lat: "25",
      lng: "121",
      types: "aed, ltc_abc",
    });
    expect(parsed.types).toEqual(["aed", "ltc_abc"]);
  });

  it("rejects an unknown resource type", () => {
    expect(() =>
      listResourcesQuerySchema.parse({ lat: "25", lng: "121", types: "bogus" }),
    ).toThrow();
  });

  it("rejects out-of-range latitude", () => {
    expect(() => listResourcesQuerySchema.parse({ lat: "999", lng: "121" })).toThrow();
  });
});

describe("createReportBodySchema", () => {
  it("accepts a valid report", () => {
    const body = createReportBodySchema.parse({
      resource_id: "11111111-1111-1111-1111-111111111111",
      report_type: "wrong_location",
      user_lat: 25.04,
      user_lng: 121.56,
    });
    expect(body.report_type).toBe("wrong_location");
  });

  it("rejects a non-uuid resource_id", () => {
    expect(() =>
      createReportBodySchema.parse({
        resource_id: "not-a-uuid",
        report_type: "closed",
        user_lat: 25,
        user_lng: 121,
      }),
    ).toThrow();
  });
});
