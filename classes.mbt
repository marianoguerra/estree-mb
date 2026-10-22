///|
/// `Class`: shared by `ClassDeclaration` and `ClassExpression`.
pub(all) struct Class {
  info : NodeInfo
  id : Identifier?
  super_class : Expression?
  body : ClassBody
  /// Stage 3 decorators.
  decorators : Array[Decorator]
} derive(Debug, Eq)

///|
/// `ClassBody`.
pub(all) struct ClassBody {
  info : NodeInfo
  body : Array[ClassElement]
} derive(Debug, Eq)

///|
/// A member of a class body.
pub(all) enum ClassElement {
  Method(MethodDefinition)
  Property(PropertyDefinition)
  /// Stage 3 `accessor` field.
  Accessor(AccessorProperty)
  StaticBlock(StaticBlock)
} derive(Debug, Eq)

///|
/// `MethodDefinition.kind`.
pub(all) enum MethodKind {
  Constructor
  Method
  Get
  Set
} derive(Debug, Eq)

///|
/// `MethodDefinition`.
pub(all) struct MethodDefinition {
  info : NodeInfo
  key : PropertyKey
  /// Always a function expression.
  value : Function
  kind : MethodKind
  is_static : Bool
  decorators : Array[Decorator]
} derive(Debug, Eq)

///|
/// `PropertyDefinition` (ES2022 class field).
pub(all) struct PropertyDefinition {
  info : NodeInfo
  key : PropertyKey
  value : Expression?
  is_static : Bool
  decorators : Array[Decorator]
} derive(Debug, Eq)

///|
/// `AccessorProperty` (stage 3 decorators): `accessor x = 1`.
pub(all) struct AccessorProperty {
  info : NodeInfo
  key : PropertyKey
  value : Expression?
  is_static : Bool
  decorators : Array[Decorator]
} derive(Debug, Eq)

///|
/// `StaticBlock` (ES2022): `static { ... }`.
pub(all) struct StaticBlock {
  info : NodeInfo
  body : Array[Statement]
} derive(Debug, Eq)

///|
/// `Decorator` (stage 3): `@expression`.
pub(all) struct Decorator {
  info : NodeInfo
  expression : Expression
} derive(Debug, Eq)

///|
pub fn MethodKind::to_string(self : MethodKind) -> String {
  match self {
    Constructor => "constructor"
    Method => "method"
    Get => "get"
    Set => "set"
  }
}

///|
pub fn MethodKind::parse(s : StringView) -> MethodKind? {
  match s {
    "constructor" => Some(Constructor)
    "method" => Some(Method)
    "get" => Some(Get)
    "set" => Some(Set)
    _ => None
  }
}
