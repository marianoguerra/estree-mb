///|
/// `TemplateLiteral`: `quasis` interleave with `expressions`.
pub(all) struct TemplateLiteral {
  info : NodeInfo
  quasis : Array[TemplateElement]
  expressions : Array[Expression]
} derive(Debug, Eq)

///|
/// `TemplateElement`: a literal chunk of a template.
pub(all) struct TemplateElement {
  info : NodeInfo
  is_tail : Bool
  /// `None` for invalid escapes in tagged templates (ES2018).
  cooked : String?
  raw : String
} derive(Debug, Eq)

///|
/// `TaggedTemplateExpression`.
pub(all) struct TaggedTemplateExpression {
  info : NodeInfo
  tag : Expression
  quasi : TemplateLiteral
} derive(Debug, Eq)
