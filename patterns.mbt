///|
/// `Pattern`: binding and assignment targets.
pub(all) enum Pattern {
  Identifier(Identifier)
  /// Only valid as an assignment target.
  Member(MemberExpression)
  Object(ObjectPattern)
  Array(ArrayPattern)
  Rest(RestElement)
  Assignment(AssignmentPattern)
} derive(Debug, Eq)

///|
/// `ObjectPattern`.
pub(all) struct ObjectPattern {
  info : NodeInfo
  properties : Array[ObjectPatternMember]
} derive(Debug, Eq)

///|
/// A member of an object pattern.
pub(all) enum ObjectPatternMember {
  Property(AssignmentProperty)
  Rest(RestElement)
} derive(Debug, Eq)

///|
/// `AssignmentProperty`: a `Property` inside an `ObjectPattern`
/// (always `kind: "init"`, `method: false`).
pub(all) struct AssignmentProperty {
  info : NodeInfo
  key : PropertyKey
  value : Pattern
  is_shorthand : Bool
} derive(Debug, Eq)

///|
/// `ArrayPattern`; `None` elements are holes.
pub(all) struct ArrayPattern {
  info : NodeInfo
  elements : Array[Pattern?]
} derive(Debug, Eq)

///|
/// `RestElement`: `...argument`.
pub(all) struct RestElement {
  info : NodeInfo
  argument : Pattern
} derive(Debug, Eq)

///|
/// `AssignmentPattern`: `left = right` default value.
pub(all) struct AssignmentPattern {
  info : NodeInfo
  left : Pattern
  right : Expression
} derive(Debug, Eq)
