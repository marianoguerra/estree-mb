///|
/// `Function`: shared by `FunctionDeclaration` and `FunctionExpression`.
///
/// `id` is `None` for anonymous function expressions and for
/// `export default function () {}`.
pub(all) struct Function {
  info : NodeInfo
  id : Identifier?
  params : Array[Pattern]
  body : FunctionBody
  is_generator : Bool
  is_async : Bool
} derive(Debug, Eq)

///|
/// `FunctionBody`: a `BlockStatement` whose directive prologue is split out.
pub(all) struct FunctionBody {
  info : NodeInfo
  directives : Array[Directive]
  body : Array[Statement]
} derive(Debug, Eq)

///|
/// `ArrowFunctionExpression`. The ESTree `expression` flag is derived from
/// `body`.
pub(all) struct ArrowFunctionExpression {
  info : NodeInfo
  params : Array[Pattern]
  body : ArrowBody
  is_async : Bool
} derive(Debug, Eq)

///|
/// Body of an arrow function.
pub(all) enum ArrowBody {
  Block(FunctionBody)
  Expression(Expression)
} derive(Debug, Eq)
