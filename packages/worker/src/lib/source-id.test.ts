import { describe, it, expect } from "vitest";
import { stableSourceId } from "./source-id";

describe("stableSourceId", () => {
  it("uses the provided id when present", () => {
    expect(stableSourceId("A1", "據點", 25, 121)).toBe("A1");
    expect(stableSourceId("  A2 ", "據點", 25, 121)).toBe("A2");
  });

  it("synthesizes a stable non-null key when id is missing", () => {
    const a = stableSourceId(null, "信義AED", 25.033, 121.564);
    const b = stableSourceId(undefined, "信義AED", 25.033, 121.564);
    const c = stableSourceId("", "信義AED", 25.033, 121.564);
    expect(a).toBe("gen:信義AED|25.033|121.564");
    expect(a).toBe(b);
    expect(a).toBe(c);
  });

  it("produces different keys for different physical resources", () => {
    expect(stableSourceId(null, "A", 25, 121)).not.toBe(
      stableSourceId(null, "B", 25, 121),
    );
  });
});
