const { a, b: { c }, d = 1, ["e"]: f, ...rest } = obj;
const [g, , h = 2, ...tail] = arr;
let [[i], { j }] = nested;
({ a, b } = obj);
[a, b] = [b, a];
[a.b, c[d]] = pair;
({ x: obj.y = 1 } = src);
function params({ a, b = 1 }, [c, d], e = 3, ...others) {}
for (const [k, v] of entries) {}
for ({ a } of list) {}
for (x of y) {}
for (let x in y) {}
try {} catch ({ message }) {}
