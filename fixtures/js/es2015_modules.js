import def from "a";
import * as ns from "b";
import { x, y as z, default as w } from "c";
import def2, { q } from "d";
import def3, * as ns2 from "e";
import "side-effect";
import {} from "empty";
export const one = 1;
export let two = 2, three;
export function fn() {}
export class Cls {}
export { one as uno, two as dos };
export { x as ex, y } from "c";
export * from "all";
export * as named from "all2";
export { default as def1 } from "def";
export { default as other } from "def2";
export default function () {}
