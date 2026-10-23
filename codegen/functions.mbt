///|
/// Writes a function declaration or expression.
fn Printer::function(self : Printer, f : Function) -> Unit {
  if f.is_async {
    self.write("async ")
  }
  self.write(if f.is_generator { "function* " } else { "function " })
  if f.id is Some(id) {
    self.identifier(id)
  }
  self.sequence(f.params, p => self.pattern(p))
  self.write(" ")
  self.function_body(f.body)
}

///|
/// Writes a function body, directive prologue first.
fn Printer::function_body(self : Printer, body : FunctionBody) -> Unit {
  let directives = body.directives.length()
  self.braced(directives + body.body.length(), i => {
    if i < directives {
      self.directive(body.directives[i])
    } else {
      self.statement(body.body[i - directives])
    }
  })
}

///|
fn Printer::directive(self : Printer, d : Directive) -> Unit {
  self.literal(d.expression)
  self.write(";")
}

///|
/// Writes the head and body of a method: `[kind][async ][*]key(params) {...}`.
fn Printer::method_like(
  self : Printer,
  kind : String,
  key : PropertyKey,
  f : Function,
) -> Unit {
  self.write(kind)
  if f.is_async {
    self.write("async ")
  }
  if f.is_generator {
    self.write("*")
  }
  self.property_key(key)
  self.sequence(f.params, p => self.pattern(p))
  self.write(" ")
  self.function_body(f.body)
}
