"use strict-ish";
'another directive';
var a = 1, b;
;
debugger;
with (obj) { a; }
function f(x, y) {
  "use strict";
  if (x) return x; else if (y) { return; } else return y;
}
outer: for (var i = 0; i < 10; i++) {
  for (;;) { break outer; }
  continue outer;
}
for (i in obj) {}
for (var k in obj) break;
while (a) a--;
do { b++; } while (b < 3);
switch (a) {
  case 1: a = 2; break;
  case "x":
  default: throw new Error("bad");
}
try { a(); } catch (e) { b(); } finally { c(); }
try { a(); } catch (e) {}
try { a(); } finally {}
