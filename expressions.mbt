///|
/// `Expression`: every ESTree node that can appear in expression position.
pub(all) enum Expression {
  Identifier(Identifier)
  Literal(Literal)
  This(NodeInfo)
  Array(ArrayExpression)
  Object(ObjectExpression)
  /// `FunctionExpression`.
  Function(Function)
  Arrow(ArrowFunctionExpression)
  /// `ClassExpression`.
  Class(Class)
  Template(TemplateLiteral)
  TaggedTemplate(TaggedTemplateExpression)
  Unary(UnaryExpression)
  Update(UpdateExpression)
  Binary(BinaryExpression)
  Logical(LogicalExpression)
  Assignment(AssignmentExpression)
  Conditional(ConditionalExpression)
  Call(CallExpression)
  New(NewExpression)
  Member(MemberExpression)
  Sequence(SequenceExpression)
  Yield(YieldExpression)
  Await(AwaitExpression)
  Chain(ChainExpression)
  Import(ImportExpression)
  MetaProperty(MetaProperty)
} derive(Debug, Eq)

///|
/// Callee of a call or object of a member expression: an expression or `super`.
pub(all) enum ExpressionOrSuper {
  Expression(Expression)
  Super(NodeInfo)
} derive(Debug, Eq)

///|
/// A call argument or array element: an expression or a `SpreadElement`.
pub(all) enum Argument {
  Expression(Expression)
  Spread(SpreadElement)
} derive(Debug, Eq)

///|
/// `SpreadElement`: `...argument`.
pub(all) struct SpreadElement {
  info : NodeInfo
  argument : Expression
} derive(Debug, Eq)

///|
/// `ArrayExpression`; `None` elements are holes (`[a, , b]`).
pub(all) struct ArrayExpression {
  info : NodeInfo
  elements : Array[Argument?]
} derive(Debug, Eq)

///|
/// `ObjectExpression`.
pub(all) struct ObjectExpression {
  info : NodeInfo
  properties : Array[ObjectMember]
} derive(Debug, Eq)

///|
/// A member of an object literal.
pub(all) enum ObjectMember {
  Property(Property)
  Spread(SpreadElement)
} derive(Debug, Eq)

///|
/// Key of an object property or class member.
///
/// The ESTree `computed` flag is encoded by the `Computed` variant.
pub(all) enum PropertyKey {
  Identifier(Identifier)
  Literal(Literal)
  Private(PrivateIdentifier)
  Computed(Expression)
} derive(Debug, Eq)

///|
pub fn PropertyKey::is_computed(self : PropertyKey) -> Bool {
  self is Computed(_)
}

///|
/// `Property.kind`.
pub(all) enum PropertyKind {
  Init
  Get
  Set
} derive(Debug, Eq)

///|
/// `Property` in an object literal.
pub(all) struct Property {
  info : NodeInfo
  key : PropertyKey
  value : Expression
  kind : PropertyKind
  is_method : Bool
  is_shorthand : Bool
} derive(Debug, Eq)

///|
/// `UnaryExpression`.
pub(all) struct UnaryExpression {
  info : NodeInfo
  operator : UnaryOperator
  /// Always `true` for ESTree-conforming input.
  is_prefix : Bool
  argument : Expression
} derive(Debug, Eq)

///|
/// `UpdateExpression`.
pub(all) struct UpdateExpression {
  info : NodeInfo
  operator : UpdateOperator
  argument : Expression
  is_prefix : Bool
} derive(Debug, Eq)

///|
/// Left operand of a `BinaryExpression`; a private name only in `#x in obj`.
pub(all) enum BinaryLeft {
  Expression(Expression)
  Private(PrivateIdentifier)
} derive(Debug, Eq)

///|
/// `BinaryExpression`.
pub(all) struct BinaryExpression {
  info : NodeInfo
  operator : BinaryOperator
  left : BinaryLeft
  right : Expression
} derive(Debug, Eq)

///|
/// `AssignmentExpression`.
pub(all) struct AssignmentExpression {
  info : NodeInfo
  operator : AssignmentOperator
  left : Pattern
  right : Expression
} derive(Debug, Eq)

///|
/// `LogicalExpression`.
pub(all) struct LogicalExpression {
  info : NodeInfo
  operator : LogicalOperator
  left : Expression
  right : Expression
} derive(Debug, Eq)

///|
/// Property of a `MemberExpression`.
///
/// The ESTree `computed` flag is encoded by the `Computed` variant.
pub(all) enum MemberProperty {
  Identifier(Identifier)
  Private(PrivateIdentifier)
  Computed(Expression)
} derive(Debug, Eq)

///|
/// `MemberExpression`.
pub(all) struct MemberExpression {
  info : NodeInfo
  object : ExpressionOrSuper
  property : MemberProperty
  /// `?.` access (ES2020 `ChainElement.optional`).
  is_optional : Bool
} derive(Debug, Eq)

///|
/// `ConditionalExpression`.
pub(all) struct ConditionalExpression {
  info : NodeInfo
  test_ : Expression
  consequent : Expression
  alternate : Expression
} derive(Debug, Eq)

///|
/// `CallExpression`.
pub(all) struct CallExpression {
  info : NodeInfo
  callee : ExpressionOrSuper
  arguments : Array[Argument]
  /// `?.()` call (ES2020 `ChainElement.optional`).
  is_optional : Bool
} derive(Debug, Eq)

///|
/// `NewExpression`.
pub(all) struct NewExpression {
  info : NodeInfo
  callee : Expression
  arguments : Array[Argument]
} derive(Debug, Eq)

///|
/// `SequenceExpression`.
pub(all) struct SequenceExpression {
  info : NodeInfo
  expressions : Array[Expression]
} derive(Debug, Eq)

///|
/// `YieldExpression`.
pub(all) struct YieldExpression {
  info : NodeInfo
  argument : Expression?
  is_delegate : Bool
} derive(Debug, Eq)

///|
/// `AwaitExpression`.
pub(all) struct AwaitExpression {
  info : NodeInfo
  argument : Expression
} derive(Debug, Eq)

///|
/// Element of an optional chain.
pub(all) enum ChainElement {
  Call(CallExpression)
  Member(MemberExpression)
} derive(Debug, Eq)

///|
/// `ChainExpression` (ES2020): wraps an optional chain such as `a?.b.c()`.
pub(all) struct ChainExpression {
  info : NodeInfo
  expression : ChainElement
} derive(Debug, Eq)

///|
/// `ImportExpression`: dynamic `import(source, options)`.
pub(all) struct ImportExpression {
  info : NodeInfo
  source : Expression
  /// ES2025 import options argument.
  options : Expression?
  /// Stage 3 `import.source(...)` / `import.defer(...)`.
  phase : ImportPhase?
} derive(Debug, Eq)

///|
/// `MetaProperty`: `new.target` and `import.meta`.
pub(all) struct MetaProperty {
  info : NodeInfo
  meta : Identifier
  property : Identifier
} derive(Debug, Eq)

///|
pub fn PropertyKind::to_string(self : PropertyKind) -> String {
  match self {
    Init => "init"
    Get => "get"
    Set => "set"
  }
}

///|
pub fn PropertyKind::parse(s : StringView) -> PropertyKind? {
  match s {
    "init" => Some(Init)
    "get" => Some(Get)
    "set" => Some(Set)
    _ => None
  }
}
