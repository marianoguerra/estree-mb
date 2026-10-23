///|
fn Printer::expression(self : Printer, e : Expression) -> Unit {
  match e {
    Identifier(x) => self.identifier(x)
    Literal(x) => self.literal(x)
    This(_) => self.write("this")
    Array(x) =>
      self.array(x.elements, element => {
        match element {
          Expression(e) => self.expression(e)
          Spread(s) => self.spread(s.argument)
        }
      })
    Object(x) => self.object(x.properties)
    Function(x) => self.function(x)
    Arrow(x) => {
      if x.is_async {
        self.write("async ")
      }
      // A lone identifier parameter needs no parentheses.
      if x.params is [Identifier(id)] {
        self.identifier(id)
      } else {
        self.sequence(x.params, p => self.pattern(p))
      }
      self.write(" => ")
      match x.body {
        Block(body) => self.function_body(body)
        Expression(Object(o)) => {
          self.write("(")
          self.object(o.properties)
          self.write(")")
        }
        Expression(body) => self.expression(body)
      }
    }
    Class(x) => self.class(x)
    Template(x) => self.template(x)
    TaggedTemplate(x) => {
      self.operand(x.tag, parent=20, parent_op="")
      self.template(x.quasi)
    }
    Unary(x) => {
      let op = x.operator.to_string()
      self.write(op)
      let parens = needs_parens(x.argument, 15, op, false)
      let doubled_sign = (op == "+" || op == "-") &&
        (match x.argument {
          Unary({ operator, is_prefix: true, .. }) =>
            operator.to_string().has_prefix(op)
          Update({ operator, is_prefix: true, .. }) =>
            operator.to_string().has_prefix(op)
          _ => false
        })
      if !parens && (op.length() > 1 || doubled_sign) {
        self.write(" ")
      }
      if parens {
        self.write(if op.length() > 1 { " (" } else { "(" })
        self.expression(x.argument)
        self.write(")")
      } else {
        self.expression(x.argument)
      }
    }
    Update(x) =>
      if x.is_prefix {
        self.write(x.operator.to_string())
        self.expression(x.argument)
      } else {
        self.expression(x.argument)
        self.write(x.operator.to_string())
      }
    Binary(x) => {
      let op = x.operator.to_string()
      // `in` is always parenthesized to avoid confusion in `for` heads.
      let is_in = x.operator is In
      if is_in {
        self.write("(")
      }
      match x.left {
        Expression(left) => self.operand(left, parent=14, parent_op=op)
        Private(id) => self.write("#\{id.name}")
      }
      self.write(" \{op} ")
      self.operand(x.right, parent=14, parent_op=op, is_right=true)
      if is_in {
        self.write(")")
      }
    }
    Logical(x) => {
      let op = x.operator.to_string()
      self.operand(x.left, parent=13, parent_op=op)
      self.write(" \{op} ")
      self.operand(x.right, parent=13, parent_op=op, is_right=true)
    }
    Assignment(x) => {
      self.pattern(x.left)
      self.write(" \{x.operator.to_string()} ")
      self.expression(x.right)
    }
    Conditional(x) => {
      let p = precedence(x.test_)
      if p == NEEDS_PARENS || p <= 4 {
        self.parenthesized(x.test_)
      } else {
        self.expression(x.test_)
      }
      self.write(" ? ")
      self.expression(x.consequent)
      self.write(" : ")
      self.expression(x.alternate)
    }
    Call(x) => self.call(x)
    New(x) => {
      self.write("new ")
      if needs_callee_parens(x.callee) || has_call_expression(x.callee) {
        self.parenthesized(x.callee)
      } else {
        self.expression(x.callee)
      }
      self.sequence(x.arguments, a => self.argument(a))
    }
    Member(x) => self.member_expression(x)
    Sequence(x) => self.sequence(x.expressions, e => self.expression(e))
    Yield(x) => {
      self.write(if x.is_delegate { "yield*" } else { "yield" })
      if x.argument is Some(argument) {
        self.write(" ")
        self.expression(argument)
      }
    }
    Await(x) => {
      self.write("await ")
      self.operand(x.argument, parent=15, parent_op="")
    }
    Chain(x) =>
      match x.expression {
        Call(c) => self.call(c)
        Member(m) => self.member_expression(m)
      }
    Import(x) => {
      // astring prints neither `options` nor the stage 3 phase.
      self.write("import")
      if x.phase is Some(phase) {
        self.write(".\{phase.to_string()}")
      }
      self.write("(")
      self.expression(x.source)
      if x.options is Some(options) {
        self.write(", ")
        self.expression(options)
      }
      self.write(")")
    }
    MetaProperty(x) => self.write("\{x.meta.name}.\{x.property.name}")
  }
}

///|
fn Printer::parenthesized(self : Printer, e : Expression) -> Unit {
  self.write("(")
  self.expression(e)
  self.write(")")
}

///|
/// astring's `formatExpression`: writes `e` as an operand of a parent with
/// precedence `parent`, parenthesizing it when needed.
fn Printer::operand(
  self : Printer,
  e : Expression,
  parent~ : Int32,
  parent_op~ : String,
  is_right~ : Bool = false,
) -> Unit {
  if needs_parens(e, parent, parent_op, is_right) {
    self.parenthesized(e)
  } else {
    self.expression(e)
  }
}

///|
/// Whether `e` needs parentheses as a callee or member object.
///
/// Unlike astring, a `ChainExpression` is parenthesized: `(a?.b).c` and
/// `(a?.b)()` end the optional chain, while `a?.b.c` and `a?.b()` continue it.
fn needs_callee_parens(e : Expression) -> Bool {
  let p = precedence(e)
  p == NEEDS_PARENS || p < CALL_PRECEDENCE || e is Chain(_)
}

///|
fn Printer::callee(self : Printer, callee : ExpressionOrSuper) -> Unit {
  match callee {
    Super(_) => self.write("super")
    Expression(e) =>
      if needs_callee_parens(e) {
        self.parenthesized(e)
      } else {
        self.expression(e)
      }
  }
}

///|
fn Printer::call(self : Printer, x : CallExpression) -> Unit {
  self.callee(x.callee)
  if x.is_optional {
    self.write("?.")
  }
  self.sequence(x.arguments, a => self.argument(a))
}

///|
fn Printer::member_expression(self : Printer, x : MemberExpression) -> Unit {
  self.callee(x.object)
  match x.property {
    Computed(property) => {
      if x.is_optional {
        self.write("?.")
      }
      self.write("[")
      self.expression(property)
      self.write("]")
    }
    Identifier(id) => {
      self.write(if x.is_optional { "?." } else { "." })
      self.identifier(id)
    }
    Private(id) => {
      self.write(if x.is_optional { "?." } else { "." })
      self.write("#\{id.name}")
    }
  }
}

///|
fn Printer::argument(self : Printer, a : Argument) -> Unit {
  match a {
    Expression(e) => self.expression(e)
    Spread(s) => self.spread(s.argument)
  }
}

///|
fn Printer::spread(self : Printer, argument : Expression) -> Unit {
  self.write("...")
  self.expression(argument)
}

///|
/// Writes `[a, , b]`; shared by array expressions and patterns. A trailing
/// hole gets an extra `, ` so that it is not swallowed.
fn[T] Printer::array(
  self : Printer,
  elements : Array[T?],
  element : (T) -> Unit,
) -> Unit {
  self.write("[")
  let n = elements.length()
  for i, item in elements {
    if item is Some(x) {
      element(x)
    }
    if i + 1 < n {
      self.write(", ")
    } else if item is None {
      self.write(", ")
    }
  }
  self.write("]")
}

///|
/// Writes an object literal with one member per line.
fn Printer::object(self : Printer, members : Array[ObjectMember]) -> Unit {
  let indent = self.indentation(self.level)
  self.level += 1
  self.write("{")
  if !members.is_empty() {
    self.write(self.line_end)
    let member_indent = indent + self.indent
    for i, m in members {
      if i > 0 {
        self.write(",")
        self.write(self.line_end)
      }
      self.write(member_indent)
      match m {
        Property(p) => self.property(p)
        Spread(s) => self.spread(s.argument)
      }
    }
    self.write(self.line_end)
    self.write(indent)
  }
  self.write("}")
  self.level -= 1
}

///|
fn Printer::property(self : Printer, p : Property) -> Unit {
  if p.is_method || !(p.kind is Init) {
    guard p.value is Function(f) else {
      // Malformed: a method whose value is not a function expression.
      self.property_key(p.key)
      self.write(": ")
      self.expression(p.value)
      return
    }
    let kind = match p.kind {
      Get => "get "
      Set => "set "
      Init => ""
    }
    self.method_like(kind, p.key, f)
    return
  }
  if !p.is_shorthand {
    self.property_key(p.key)
    self.write(": ")
  }
  self.expression(p.value)
}

///|
fn Printer::property_key(self : Printer, key : PropertyKey) -> Unit {
  match key {
    Identifier(id) => self.identifier(id)
    Literal(l) => self.literal(l)
    Private(id) => self.write("#\{id.name}")
    Computed(e) => {
      self.write("[")
      self.expression(e)
      self.write("]")
    }
  }
}

///|
fn Printer::template(self : Printer, t : TemplateLiteral) -> Unit {
  self.write("`")
  for i, quasi in t.quasis {
    self.write(quasi.raw)
    if t.expressions.get(i) is Some(e) {
      self.write("${")
      self.expression(e)
      self.write("}")
    }
  }
  self.write("`")
}
