function* gen() { yield; yield 1; yield* other(); }
const arrow1 = () => 1;
const arrow2 = (a, b) => { return a + b; };
const arrow3 = x => ({ x });
const arrow4 = () => { "use strict"; };
let { length } = "abc";
class A {}
class B extends A {
  constructor(x) { super(x); this.x = x; }
  method() { return super.method(); }
  static create() { return new.target; }
  get value() { return 1; }
  set value(v) {}
  *items() {}
  ["computed" + 1]() {}
  static [Symbol.iterator]() {}
  "string key"() {}
  42() {}
}
const C = class {};
const D = class Named extends (A, B) {};
const obj = { a, b, method() {}, *gen() {}, [key]: 1, ["k" + 1]() {}, get [x]() {} };
f(...args, ...[1, 2]);
new F(...args);
[...a, b];
