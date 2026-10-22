class P {
  x;
  y = 1;
  static z = 2;
  #priv = 3;
  static #spriv;
  ["computed"] = 4;
  "quoted" = 5;
  static {
    this.z = 3;
  }
  static {}
  #method() { return this.#priv; }
  get #g() { return 1; }
  static #sm() {}
  has(o) { return #priv in o; }
  [k];
  constructor() { this.#priv++; }
}
await something;
export { a as "string name" };
export { "string local" as b } from "m";
import { "string import" as c } from "m";
export * as "ns string" from "m";
const a = 1;
