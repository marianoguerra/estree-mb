///|
/// `Statement`.
pub(all) enum Statement {
  Expression(ExpressionStatement)
  Block(BlockStatement)
  Empty(NodeInfo)
  Debugger(NodeInfo)
  With(WithStatement)
  Return(ReturnStatement)
  Labeled(LabeledStatement)
  Break(BreakStatement)
  Continue(ContinueStatement)
  If(IfStatement)
  Switch(SwitchStatement)
  Throw(ThrowStatement)
  Try(TryStatement)
  While(WhileStatement)
  DoWhile(DoWhileStatement)
  For(ForStatement)
  ForIn(ForInStatement)
  ForOf(ForOfStatement)
  Declaration(Declaration)
} derive(Debug, Eq)

///|
/// `ExpressionStatement` (directives are modeled separately as `Directive`).
pub(all) struct ExpressionStatement {
  info : NodeInfo
  expression : Expression
} derive(Debug, Eq)

///|
/// `BlockStatement`.
pub(all) struct BlockStatement {
  info : NodeInfo
  body : Array[Statement]
} derive(Debug, Eq)

///|
/// `WithStatement`.
pub(all) struct WithStatement {
  info : NodeInfo
  object : Expression
  body : Statement
} derive(Debug, Eq)

///|
/// `ReturnStatement`.
pub(all) struct ReturnStatement {
  info : NodeInfo
  argument : Expression?
} derive(Debug, Eq)

///|
/// `LabeledStatement`.
pub(all) struct LabeledStatement {
  info : NodeInfo
  label : Identifier
  body : Statement
} derive(Debug, Eq)

///|
/// `BreakStatement`.
pub(all) struct BreakStatement {
  info : NodeInfo
  label : Identifier?
} derive(Debug, Eq)

///|
/// `ContinueStatement`.
pub(all) struct ContinueStatement {
  info : NodeInfo
  label : Identifier?
} derive(Debug, Eq)

///|
/// `IfStatement`.
pub(all) struct IfStatement {
  info : NodeInfo
  test_ : Expression
  consequent : Statement
  alternate : Statement?
} derive(Debug, Eq)

///|
/// `SwitchStatement`.
pub(all) struct SwitchStatement {
  info : NodeInfo
  discriminant : Expression
  cases : Array[SwitchCase]
} derive(Debug, Eq)

///|
/// `SwitchCase`; `test` is `None` for `default:`.
pub(all) struct SwitchCase {
  info : NodeInfo
  test_ : Expression?
  consequent : Array[Statement]
} derive(Debug, Eq)

///|
/// `ThrowStatement`.
pub(all) struct ThrowStatement {
  info : NodeInfo
  argument : Expression
} derive(Debug, Eq)

///|
/// `TryStatement`.
pub(all) struct TryStatement {
  info : NodeInfo
  block : BlockStatement
  handler : CatchClause?
  finalizer : BlockStatement?
} derive(Debug, Eq)

///|
/// `CatchClause`; `param` is optional since ES2019.
pub(all) struct CatchClause {
  info : NodeInfo
  param : Pattern?
  body : BlockStatement
} derive(Debug, Eq)

///|
/// `WhileStatement`.
pub(all) struct WhileStatement {
  info : NodeInfo
  test_ : Expression
  body : Statement
} derive(Debug, Eq)

///|
/// `DoWhileStatement`.
pub(all) struct DoWhileStatement {
  info : NodeInfo
  body : Statement
  test_ : Expression
} derive(Debug, Eq)

///|
/// Initializer of a `ForStatement`.
pub(all) enum ForInit {
  Variable(VariableDeclaration)
  Expression(Expression)
} derive(Debug, Eq)

///|
/// `ForStatement`.
pub(all) struct ForStatement {
  info : NodeInfo
  init : ForInit?
  test_ : Expression?
  update : Expression?
  body : Statement
} derive(Debug, Eq)

///|
/// Left side of `for-in` / `for-of`.
pub(all) enum ForInLeft {
  Variable(VariableDeclaration)
  Pattern(Pattern)
} derive(Debug, Eq)

///|
/// `ForInStatement`.
pub(all) struct ForInStatement {
  info : NodeInfo
  left : ForInLeft
  right : Expression
  body : Statement
} derive(Debug, Eq)

///|
/// `ForOfStatement`; `is_await` marks `for await (...)` (ES2018).
pub(all) struct ForOfStatement {
  info : NodeInfo
  left : ForInLeft
  right : Expression
  body : Statement
  is_await : Bool
} derive(Debug, Eq)
