///|
pub impl ToJson for Expression with fn to_json(self) {
  match self {
    Identifier(x) => Json(x)
    Literal(x) => Json(x)
    This(info) => node("ThisExpression", info, [])
    Array(x) => Json(x)
    Object(x) => Json(x)
    Function(x) => x.encode("FunctionExpression")
    Arrow(x) => Json(x)
    Class(x) => x.encode("ClassExpression")
    Template(x) => Json(x)
    TaggedTemplate(x) => Json(x)
    Unary(x) => Json(x)
    Update(x) => Json(x)
    Binary(x) => Json(x)
    Logical(x) => Json(x)
    Assignment(x) => Json(x)
    Conditional(x) => Json(x)
    Call(x) => Json(x)
    New(x) => Json(x)
    Member(x) => Json(x)
    Sequence(x) => Json(x)
    Yield(x) => Json(x)
    Await(x) => Json(x)
    Chain(x) => Json(x)
    Import(x) => Json(x)
    MetaProperty(x) => Json(x)
  }
}

///|
fn Expression::decode(o : Obj) -> Expression raise @json.JsonDecodeError {
  match o.type_() {
    "Identifier" => Identifier(Identifier::decode(o))
    "Literal" => Literal(Literal::decode(o))
    "ThisExpression" => This(o.info())
    "ArrayExpression" => Array(ArrayExpression::decode(o))
    "ObjectExpression" => Object(ObjectExpression::decode(o))
    "FunctionExpression" => Function(Function::decode(o))
    "ArrowFunctionExpression" => Arrow(ArrowFunctionExpression::decode(o))
    "ClassExpression" => Class(Class::decode(o))
    "TemplateLiteral" => Template(TemplateLiteral::decode(o))
    "TaggedTemplateExpression" =>
      TaggedTemplate(TaggedTemplateExpression::decode(o))
    "UnaryExpression" => Unary(UnaryExpression::decode(o))
    "UpdateExpression" => Update(UpdateExpression::decode(o))
    "BinaryExpression" => Binary(BinaryExpression::decode(o))
    "LogicalExpression" => Logical(LogicalExpression::decode(o))
    "AssignmentExpression" => Assignment(AssignmentExpression::decode(o))
    "ConditionalExpression" => Conditional(ConditionalExpression::decode(o))
    "CallExpression" => Call(CallExpression::decode(o))
    "NewExpression" => New(NewExpression::decode(o))
    "MemberExpression" => Member(MemberExpression::decode(o))
    "SequenceExpression" => Sequence(SequenceExpression::decode(o))
    "YieldExpression" => Yield(YieldExpression::decode(o))
    "AwaitExpression" => Await(AwaitExpression::decode(o))
    "ChainExpression" => Chain(ChainExpression::decode(o))
    "ImportExpression" => Import(ImportExpression::decode(o))
    "MetaProperty" => MetaProperty(MetaProperty::decode(o))
    other => o.unexpected_type("expression", other)
  }
}

///|
pub impl FromJson for Expression with fn from_json(json, path) {
  Expression::decode(Obj::new(json, path))
}

///|
pub impl ToJson for ExpressionOrSuper with fn to_json(self) {
  match self {
    Expression(x) => Json(x)
    Super(info) => node("Super", info, [])
  }
}

///|
pub impl FromJson for ExpressionOrSuper with fn from_json(json, path) {
  let o = Obj::new(json, path)
  match o.type_() {
    "Super" => Super(o.info())
    _ => Expression(Expression::decode(o))
  }
}

///|
pub impl ToJson for Argument with fn to_json(self) {
  match self {
    Expression(x) => Json(x)
    Spread(x) => Json(x)
  }
}

///|
pub impl FromJson for Argument with fn from_json(json, path) {
  let o = Obj::new(json, path)
  match o.type_() {
    "SpreadElement" => Spread(SpreadElement::decode(o))
    _ => Expression(Expression::decode(o))
  }
}

///|
pub impl ToJson for SpreadElement with fn to_json(self) {
  node("SpreadElement", self.info, [("argument", Json(self.argument))])
}

///|
fn SpreadElement::decode(o : Obj) -> SpreadElement raise @json.JsonDecodeError {
  { info: o.info(), argument: o.get("argument"), }
}

///|
pub impl FromJson for SpreadElement with fn from_json(json, path) {
  let o = Obj::new(json, path)
  o.expect_type("SpreadElement")
  SpreadElement::decode(o)
}

///|
pub impl ToJson for ArrayExpression with fn to_json(self) {
  node("ArrayExpression", self.info, [("elements", sparse(self.elements))])
}

///|
fn ArrayExpression::decode(
  o : Obj,
) -> ArrayExpression raise @json.JsonDecodeError {
  { info: o.info(), elements: o.sparse_list("elements"), }
}

///|
pub impl ToJson for ObjectExpression with fn to_json(self) {
  node("ObjectExpression", self.info, [("properties", Json(self.properties))])
}

///|
fn ObjectExpression::decode(
  o : Obj,
) -> ObjectExpression raise @json.JsonDecodeError {
  { info: o.info(), properties: o.get("properties"), }
}

///|
pub impl ToJson for ObjectMember with fn to_json(self) {
  match self {
    Property(x) => Json(x)
    Spread(x) => Json(x)
  }
}

///|
pub impl FromJson for ObjectMember with fn from_json(json, path) {
  let o = Obj::new(json, path)
  match o.type_() {
    "Property" => Property(Property::decode(o))
    "SpreadElement" => Spread(SpreadElement::decode(o))
    other => o.unexpected_type("object member", other)
  }
}

///|
/// The `key` and `computed` fields of a property-like node.
fn PropertyKey::fields(self : PropertyKey) -> Array[(String, Json)] {
  let key = match self {
    Identifier(x) => Json(x)
    Literal(x) => Json(x)
    Private(x) => Json(x)
    Computed(x) => Json(x)
  }
  [("computed", Json(self.is_computed())), ("key", key)]
}

///|
/// Decodes the `key` field of a property-like node, folding in `computed`.
fn PropertyKey::decode(o : Obj) -> PropertyKey raise @json.JsonDecodeError {
  if o.flag("computed") {
    return Computed(o.get("key"))
  }
  let key = o.child("key")
  match key.type_() {
    "Identifier" => Identifier(Identifier::decode(key))
    "Literal" => Literal(Literal::decode(key))
    "PrivateIdentifier" => Private(PrivateIdentifier::decode(key))
    other => key.unexpected_type("non-computed key", other)
  }
}

///|
pub impl ToJson for Property with fn to_json(self) {
  node(
    "Property",
    self.info,
    [
      ("method", Json(self.is_method)),
      ("shorthand", Json(self.is_shorthand)),
      ..self.key.fields(),
      ("value", Json(self.value)),
      ("kind", Json(self.kind)),
    ],
  )
}

///|
fn Property::decode(o : Obj) -> Property raise @json.JsonDecodeError {
  {
    info: o.info(),
    key: PropertyKey::decode(o),
    value: o.get("value"),
    kind: o.get("kind"),
    is_method: o.flag("method"),
    is_shorthand: o.flag("shorthand"),
  }
}

///|
pub impl FromJson for Property with fn from_json(json, path) {
  let o = Obj::new(json, path)
  o.expect_type("Property")
  Property::decode(o)
}

///|
pub impl ToJson for UnaryExpression with fn to_json(self) {
  node("UnaryExpression", self.info, [
    ("operator", Json(self.operator)),
    ("prefix", Json(self.is_prefix)),
    ("argument", Json(self.argument)),
  ])
}

///|
fn UnaryExpression::decode(
  o : Obj,
) -> UnaryExpression raise @json.JsonDecodeError {
  {
    info: o.info(),
    operator: o.get("operator"),
    is_prefix: o.nullable("prefix").unwrap_or(true),
    argument: o.get("argument"),
  }
}

///|
pub impl ToJson for UpdateExpression with fn to_json(self) {
  node("UpdateExpression", self.info, [
    ("operator", Json(self.operator)),
    ("prefix", Json(self.is_prefix)),
    ("argument", Json(self.argument)),
  ])
}

///|
fn UpdateExpression::decode(
  o : Obj,
) -> UpdateExpression raise @json.JsonDecodeError {
  {
    info: o.info(),
    operator: o.get("operator"),
    argument: o.get("argument"),
    is_prefix: o.get("prefix"),
  }
}

///|
pub impl ToJson for BinaryLeft with fn to_json(self) {
  match self {
    Expression(x) => Json(x)
    Private(x) => Json(x)
  }
}

///|
pub impl FromJson for BinaryLeft with fn from_json(json, path) {
  let o = Obj::new(json, path)
  match o.type_() {
    "PrivateIdentifier" => Private(PrivateIdentifier::decode(o))
    _ => Expression(Expression::decode(o))
  }
}

///|
pub impl ToJson for BinaryExpression with fn to_json(self) {
  node("BinaryExpression", self.info, [
    ("left", Json(self.left)),
    ("operator", Json(self.operator)),
    ("right", Json(self.right)),
  ])
}

///|
fn BinaryExpression::decode(
  o : Obj,
) -> BinaryExpression raise @json.JsonDecodeError {
  {
    info: o.info(),
    operator: o.get("operator"),
    left: o.get("left"),
    right: o.get("right"),
  }
}

///|
pub impl ToJson for AssignmentExpression with fn to_json(self) {
  node("AssignmentExpression", self.info, [
    ("operator", Json(self.operator)),
    ("left", Json(self.left)),
    ("right", Json(self.right)),
  ])
}

///|
fn AssignmentExpression::decode(
  o : Obj,
) -> AssignmentExpression raise @json.JsonDecodeError {
  {
    info: o.info(),
    operator: o.get("operator"),
    left: o.get("left"),
    right: o.get("right"),
  }
}

///|
pub impl ToJson for LogicalExpression with fn to_json(self) {
  node("LogicalExpression", self.info, [
    ("left", Json(self.left)),
    ("operator", Json(self.operator)),
    ("right", Json(self.right)),
  ])
}

///|
fn LogicalExpression::decode(
  o : Obj,
) -> LogicalExpression raise @json.JsonDecodeError {
  {
    info: o.info(),
    operator: o.get("operator"),
    left: o.get("left"),
    right: o.get("right"),
  }
}

///|
pub impl ToJson for MemberExpression with fn to_json(self) {
  let (computed, property) = match self.property {
    Identifier(x) => (false, Json(x))
    Private(x) => (false, Json(x))
    Computed(x) => (true, Json(x))
  }
  node("MemberExpression", self.info, [
    ("object", Json(self.object)),
    ("property", property),
    ("computed", Json(computed)),
    ("optional", Json(self.is_optional)),
  ])
}

///|
fn MemberExpression::decode(
  o : Obj,
) -> MemberExpression raise @json.JsonDecodeError {
  let property : MemberProperty = if o.flag("computed") {
    Computed(o.get("property"))
  } else {
    let p = o.child("property")
    match p.type_() {
      "Identifier" => Identifier(Identifier::decode(p))
      "PrivateIdentifier" => Private(PrivateIdentifier::decode(p))
      other => p.unexpected_type("non-computed member property", other)
    }
  }
  {
    info: o.info(),
    object: o.get("object"),
    property,
    is_optional: o.flag("optional"),
  }
}

///|
pub impl FromJson for MemberExpression with fn from_json(json, path) {
  let o = Obj::new(json, path)
  o.expect_type("MemberExpression")
  MemberExpression::decode(o)
}

///|
pub impl ToJson for ConditionalExpression with fn to_json(self) {
  node("ConditionalExpression", self.info, [
    ("test", Json(self.test_)),
    ("consequent", Json(self.consequent)),
    ("alternate", Json(self.alternate)),
  ])
}

///|
fn ConditionalExpression::decode(
  o : Obj,
) -> ConditionalExpression raise @json.JsonDecodeError {
  {
    info: o.info(),
    test_: o.get("test"),
    consequent: o.get("consequent"),
    alternate: o.get("alternate"),
  }
}

///|
pub impl ToJson for CallExpression with fn to_json(self) {
  node("CallExpression", self.info, [
    ("callee", Json(self.callee)),
    ("arguments", Json(self.arguments)),
    ("optional", Json(self.is_optional)),
  ])
}

///|
fn CallExpression::decode(
  o : Obj,
) -> CallExpression raise @json.JsonDecodeError {
  {
    info: o.info(),
    callee: o.get("callee"),
    arguments: o.get("arguments"),
    is_optional: o.flag("optional"),
  }
}

///|
pub impl ToJson for NewExpression with fn to_json(self) {
  node("NewExpression", self.info, [
    ("callee", Json(self.callee)),
    ("arguments", Json(self.arguments)),
  ])
}

///|
fn NewExpression::decode(o : Obj) -> NewExpression raise @json.JsonDecodeError {
  { info: o.info(), callee: o.get("callee"), arguments: o.get("arguments"), }
}

///|
pub impl ToJson for SequenceExpression with fn to_json(self) {
  node("SequenceExpression", self.info, [
    ("expressions", Json(self.expressions)),
  ])
}

///|
fn SequenceExpression::decode(
  o : Obj,
) -> SequenceExpression raise @json.JsonDecodeError {
  { info: o.info(), expressions: o.get("expressions"), }
}

///|
pub impl ToJson for YieldExpression with fn to_json(self) {
  node("YieldExpression", self.info, [
    ("delegate", Json(self.is_delegate)),
    ("argument", nullable(self.argument)),
  ])
}

///|
fn YieldExpression::decode(
  o : Obj,
) -> YieldExpression raise @json.JsonDecodeError {
  {
    info: o.info(),
    argument: o.nullable("argument"),
    is_delegate: o.flag("delegate"),
  }
}

///|
pub impl ToJson for AwaitExpression with fn to_json(self) {
  node("AwaitExpression", self.info, [("argument", Json(self.argument))])
}

///|
fn AwaitExpression::decode(
  o : Obj,
) -> AwaitExpression raise @json.JsonDecodeError {
  { info: o.info(), argument: o.get("argument"), }
}

///|
pub impl ToJson for ChainElement with fn to_json(self) {
  match self {
    Call(x) => Json(x)
    Member(x) => Json(x)
  }
}

///|
pub impl FromJson for ChainElement with fn from_json(json, path) {
  let o = Obj::new(json, path)
  match o.type_() {
    "CallExpression" => Call(CallExpression::decode(o))
    "MemberExpression" => Member(MemberExpression::decode(o))
    other => o.unexpected_type("chain element", other)
  }
}

///|
pub impl ToJson for ChainExpression with fn to_json(self) {
  node("ChainExpression", self.info, [("expression", Json(self.expression))])
}

///|
fn ChainExpression::decode(
  o : Obj,
) -> ChainExpression raise @json.JsonDecodeError {
  { info: o.info(), expression: o.get("expression"), }
}

///|
pub impl ToJson for ImportExpression with fn to_json(self) {
  let fields = [
    ("source", Json(self.source)),
    ("options", nullable(self.options)),
  ]
  if self.phase is Some(phase) {
    fields.push(("phase", Json(phase)))
  }
  node("ImportExpression", self.info, fields)
}

///|
fn ImportExpression::decode(
  o : Obj,
) -> ImportExpression raise @json.JsonDecodeError {
  {
    info: o.info(),
    source: o.get("source"),
    options: o.nullable("options"),
    phase: o.nullable("phase"),
  }
}

///|
pub impl ToJson for MetaProperty with fn to_json(self) {
  node("MetaProperty", self.info, [
    ("meta", Json(self.meta)),
    ("property", Json(self.property)),
  ])
}

///|
fn MetaProperty::decode(o : Obj) -> MetaProperty raise @json.JsonDecodeError {
  { info: o.info(), meta: o.get("meta"), property: o.get("property"), }
}
