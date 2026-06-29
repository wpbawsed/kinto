import { describe, it, expect } from "vitest";
import { parseAedCsv, splitCsvLine } from "./ingest-aed";

describe("splitCsvLine", () => {
  it("splits a simple line", () => {
    expect(splitCsvLine("a,b,c")).toEqual(["a", "b", "c"]);
  });

  it("respects quoted commas", () => {
    expect(splitCsvLine('1,"台北市, 信義區",test')).toEqual([
      "1",
      "台北市, 信義區",
      "test",
    ]);
  });
});

describe("parseAedCsv", () => {
  const csv = [
    "id,name,address,phone,lat,lng",
    '1,台北101 AED,"台北市信義區",02-1234,25.0339,121.5645',
    "2,亂座標,某地,02-0000,0,0", // 不合法座標應剔除
    "3,無名稱,,,25.05,121.55", // name 欄有值（"無名稱"）→ 應保留
  ].join("\n");

  it("keeps only rows with valid TW coordinates", () => {
    const rows = parseAedCsv(csv);
    expect(rows).toHaveLength(2);
    expect(rows[0]!.name).toBe("台北101 AED");
    expect(rows[0]!.type).toBe("aed");
    expect(rows[0]!.sourceId).toBe("1");
  });

  it("returns empty for header-only input", () => {
    expect(parseAedCsv("id,name,lat,lng")).toEqual([]);
  });

  it("synthesizes a non-null source_id when the id column is blank", () => {
    const rows = parseAedCsv(
      ["id,name,lat,lng", ",無編號AED,25.04,121.55"].join("\n"),
    );
    expect(rows).toHaveLength(1);
    expect(rows[0]!.sourceId).toBe("gen:無編號AED|25.04|121.55");
  });
});
