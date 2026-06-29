import { describe, it, expect } from "vitest";
import { parseLtcAbcJson } from "./ingest-ltc-abc";

describe("parseLtcAbcJson", () => {
  it("parses a plain array with Chinese keys", () => {
    const rows = parseLtcAbcJson([
      {
        id: "A1",
        機構名稱: "信義區關懷據點",
        地址: "台北市信義區",
        電話: "02-1111",
        緯度: "25.033",
        經度: "121.564",
      },
    ]);
    expect(rows).toHaveLength(1);
    expect(rows[0]!.type).toBe("ltc_abc");
    expect(rows[0]!.name).toBe("信義區關懷據點");
    expect(rows[0]!.sourceId).toBe("A1");
  });

  it("unwraps result.records shape", () => {
    const rows = parseLtcAbcJson({
      result: {
        records: [{ name: "Center", lat: 24.5, lng: 121.0 }],
      },
    });
    expect(rows).toHaveLength(1);
    expect(rows[0]!.name).toBe("Center");
  });

  it("drops records with invalid coordinates or no name", () => {
    const rows = parseLtcAbcJson([
      { name: "no coord" },
      { name: "bad", lat: 0, lng: 0 },
      { lat: 25, lng: 121 }, // no name
    ]);
    expect(rows).toEqual([]);
  });
});
