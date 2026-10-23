///|
/// Writes stage 3 decorators, each followed by a space (astring has no
/// decorator support).
fn Printer::decorators(self : Printer, decorators : Array[Decorator]) -> Unit {
  for d in decorators {
    self.write("@")
    if is_simple_decorator(d.expression) {
      self.expression(d.expression)
    } else {
      self.parenthesized(d.expression)
    }
    self.write(" ")
  }
}

///|
/// Whether a decorator expression can be written without parentheses:
/// a dotted name, optionally called (`@a.b.#c`, `@a.b(args)`).
fn is_simple_decorator(e : Expression) -> Bool {
  match e {
    Call({ callee: Expression(callee), is_optional: false, .. }) =>
      is_decorator_member(callee)
    _ => is_decorator_member(e)
  }
}

///|
fn is_decorator_member(e : Expression) -> Bool {
  match e {
    Identifier(_) => true
    Member(
      {
        object: Expression(object),
        property: Identifier(_)
        | Private(_),
        is_optional: false,
        ..
      }
    ) => is_decorator_member(object)
    _ => false
  }
}

///|
/// Writes a class declaration or expression.
fn Printer::class(self : Printer, c : Class) -> Unit {
  self.decorators(c.decorators)
  self.write("class ")
  if c.id is Some(id) {
    self.identifier(id)
    self.write(" ")
  }
  if c.super_class is Some(super_class) {
    self.write("extends ")
    let p = precedence(super_class)
    if !(super_class is Class(_)) && (p == NEEDS_PARENS || p < NEEDS_PARENS) {
      self.parenthesized(super_class)
    } else {
      self.expression(super_class)
    }
    self.write(" ")
  }
  let elements = c.body.body
  self.braced(elements.length(), i => self.class_element(elements[i]))
}

///|
fn Printer::class_element(self : Printer, element : ClassElement) -> Unit {
  match element {
    Method(m) => self.method_definition(m)
    Property(p) => self.property_definition(p)
    Accessor(a) => self.accessor_property(a)
    StaticBlock(b) => {
      self.write("static ")
      self.braced(b.body.length(), i => self.statement(b.body[i]))
    }
  }
}

///|
fn Printer::method_definition(self : Printer, m : MethodDefinition) -> Unit {
  self.decorators(m.decorators)
  if m.is_static {
    self.write("static ")
  }
  let kind = match m.kind {
    Get => "get "
    Set => "set "
    Constructor | Method => ""
  }
  self.method_like(kind, m.key, m.value)
}

///|
fn Printer::property_definition(self : Printer, p : PropertyDefinition) -> Unit {
  self.decorators(p.decorators)
  self.field(p.is_static, p.key, p.value)
}

///|
fn Printer::accessor_property(self : Printer, a : AccessorProperty) -> Unit {
  self.decorators(a.decorators)
  if a.is_static {
    self.write("static ")
  }
  self.write("accessor ")
  self.field(false, a.key, a.value)
}

///|
/// Writes `[static ]key[ = value];`.
fn Printer::field(
  self : Printer,
  is_static : Bool,
  key : PropertyKey,
  value : Expression?,
) -> Unit {
  if is_static {
    self.write("static ")
  }
  self.property_key(key)
  if value is Some(value) {
    self.write(" = ")
    self.expression(value)
  }
  self.write(";")
}
