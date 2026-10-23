///|
/// Writes a statement without leading indentation or trailing line end.
fn Printer::statement(self : Printer, s : Statement) -> Unit {
  match s {
    Expression(x) => {
      let e = x.expression
      if precedence(e) == NEEDS_PARENS ||
        e is Assignment({ left: Object(_), .. }) ||
        starts_with_let_bracket(e) {
        self.parenthesized(e)
      } else {
        self.expression(e)
      }
      self.write(";")
    }
    Block(x) => self.block(x.body)
    Empty(_) => self.write(";")
    Debugger(_) => self.write("debugger;")
    With(x) => {
      self.write("with (")
      self.expression(x.object)
      self.write(") ")
      self.statement(x.body)
    }
    Return(x) => {
      self.write("return")
      if x.argument is Some(argument) {
        self.write(" ")
        self.expression(argument)
      }
      self.write(";")
    }
    Labeled(x) => {
      self.identifier(x.label)
      self.write(": ")
      self.statement(x.body)
    }
    Break(x) => self.jump("break", x.label)
    Continue(x) => self.jump("continue", x.label)
    If(x) => {
      self.write("if (")
      self.expression(x.test_)
      self.write(") ")
      self.statement(x.consequent)
      if x.alternate is Some(alternate) {
        self.write(" else ")
        self.statement(alternate)
      }
    }
    Switch(x) => {
      let indent = self.indentation(self.level)
      self.level += 2
      let case_indent = indent + self.indent
      let statement_indent = case_indent + self.indent
      self.write("switch (")
      self.expression(x.discriminant)
      self.write(") {")
      self.write(self.line_end)
      for case_ in x.cases {
        self.write(case_indent)
        match case_.test_ {
          Some(test_) => {
            self.write("case ")
            self.expression(test_)
            self.write(":")
          }
          None => self.write("default:")
        }
        self.write(self.line_end)
        for statement in case_.consequent {
          self.write(statement_indent)
          self.statement(statement)
          self.write(self.line_end)
        }
      }
      self.level -= 2
      self.write(indent)
      self.write("}")
    }
    Throw(x) => {
      self.write("throw ")
      self.expression(x.argument)
      self.write(";")
    }
    Try(x) => {
      self.write("try ")
      self.block(x.block.body)
      if x.handler is Some(handler) {
        match handler.param {
          None => self.write(" catch ")
          Some(param) => {
            self.write(" catch (")
            self.pattern(param)
            self.write(") ")
          }
        }
        self.block(handler.body.body)
      }
      if x.finalizer is Some(finalizer) {
        self.write(" finally ")
        self.block(finalizer.body)
      }
    }
    While(x) => {
      self.write("while (")
      self.expression(x.test_)
      self.write(") ")
      self.statement(x.body)
    }
    DoWhile(x) => {
      self.write("do ")
      self.statement(x.body)
      self.write(" while (")
      self.expression(x.test_)
      self.write(");")
    }
    For(x) => {
      self.write("for (")
      match x.init {
        Some(Variable(v)) => self.variable_declaration(v)
        Some(Expression(e)) => self.expression(e)
        None => ()
      }
      self.write("; ")
      if x.test_ is Some(test_) {
        self.expression(test_)
      }
      self.write("; ")
      if x.update is Some(update) {
        self.expression(update)
      }
      self.write(") ")
      self.statement(x.body)
    }
    ForIn(x) => self.for_in_of("for (", x.left, " in ", x.right, x.body)
    ForOf(x) =>
      self.for_in_of(
        if x.is_await {
          "for await ("
        } else {
          "for ("
        },
        x.left,
        " of ",
        x.right,
        x.body,
      )
    Declaration(d) => self.declaration(d)
  }
}

///|
fn Printer::block(self : Printer, body : Array[Statement]) -> Unit {
  self.braced(body.length(), i => self.statement(body[i]))
}

///|
fn Printer::jump(self : Printer, keyword : String, label : Identifier?) -> Unit {
  self.write(keyword)
  if label is Some(label) {
    self.write(" ")
    self.identifier(label)
  }
  self.write(";")
}

///|
fn Printer::for_in_of(
  self : Printer,
  head : String,
  left : ForInLeft,
  keyword : String,
  right : Expression,
  body : Statement,
) -> Unit {
  self.write(head)
  match left {
    Variable(v) => self.variable_declaration(v)
    Pattern(p) => self.pattern(p)
  }
  self.write(keyword)
  self.expression(right)
  self.write(") ")
  self.statement(body)
}

///|
fn Printer::declaration(self : Printer, d : Declaration) -> Unit {
  match d {
    Function(f) => self.function(f)
    Variable(v) => {
      self.variable_declaration(v)
      self.write(";")
    }
    Class(c) => self.class(c)
  }
}

///|
/// Writes `kind a = 1, b` without the trailing `;`.
fn Printer::variable_declaration(
  self : Printer,
  v : VariableDeclaration,
) -> Unit {
  self.write(v.kind.to_string())
  self.write(" ")
  self.comma_separated(v.declarations, d => {
    self.pattern(d.id)
    if d.init is Some(init) {
      self.write(" = ")
      self.expression(init)
    }
  })
}

///|
/// Whether an expression statement would start with `let [`, which parses as
/// a lexical declaration (astring does not guard against this).
fn starts_with_let_bracket(e : Expression) -> Bool {
  match e {
    Member(
      {
        object: Expression(Identifier({ name: "let", .. })),
        property: Computed(_),
        ..
      }
    ) => true
    Member({ object: Expression(object), .. }) =>
      starts_with_let_bracket(object)
    Call({ callee: Expression(callee), .. }) => starts_with_let_bracket(callee)
    TaggedTemplate({ tag, .. }) => starts_with_let_bracket(tag)
    Update({ argument, is_prefix: false, .. }) =>
      starts_with_let_bracket(argument)
    Assignment({ left: Member(m), .. }) => starts_with_let_bracket(Member(m))
    Binary({ left: Expression(left), .. }) => starts_with_let_bracket(left)
    Logical({ left, .. }) => starts_with_let_bracket(left)
    Conditional({ test_, .. }) => starts_with_let_bracket(test_)
    _ => false
  }
}
