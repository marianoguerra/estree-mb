///|
/// `Identifier`: a name used as an expression, pattern, label or key.
pub(all) struct Identifier {
  info : NodeInfo
  name : String
} derive(Debug, Eq)

///|
/// `PrivateIdentifier` (ES2022): `#name` in class bodies and member access.
/// `name` excludes the leading `#`.
pub(all) struct PrivateIdentifier {
  info : NodeInfo
  name : String
} derive(Debug, Eq)

///|
/// `Literal`, including the `RegExpLiteral` and `BigIntLiteral` refinements.
pub(all) struct Literal {
  info : NodeInfo
  value : LiteralValue
  /// Source text of the literal (non-spec, emitted by most parsers).
  raw : String?
} derive(Debug, Eq)

///|
/// The value carried by a `Literal`.
pub(all) enum LiteralValue {
  String(String)
  Boolean(Bool)
  Null
  Number(Double)
  /// `RegExpLiteral`: encoded as `value: null` plus `regex`.
  RegExp(pattern~ : String, flags~ : String)
  /// `BigIntLiteral`: the decimal digits, encoded as `value: null` plus `bigint`.
  BigInt(String)
} derive(Debug, Eq)

///|
/// Builds an `Identifier` with no positional information.
pub fn Identifier::named(name : String) -> Identifier {
  { info: NodeInfo::empty(), name, }
}

///|
/// Builds a string `Literal` with no positional information.
pub fn Literal::string(value : String) -> Literal {
  { info: NodeInfo::empty(), value: String(value), raw: None, }
}
