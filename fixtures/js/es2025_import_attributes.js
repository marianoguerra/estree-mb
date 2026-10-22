import json from "./data.json" with { type: "json" };
import { a } from "./mod.js" with { type: "javascript", "other-key": "v" };
export { b } from "./b.json" with { type: "json" };
export * from "./c.json" with { type: "json" };
import("./d.json", { with: { type: "json" } });
/[\p{L}--[a-z]]/v;
