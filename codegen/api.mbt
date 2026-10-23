///|
/// Generates JavaScript source for a program.
///
/// The output follows [astring](https://github.com/davidbonnet/astring)'s
/// formatting byte for byte, except where astring produces code that does
/// not reparse to the same AST (see the README). Literals are written from
/// their `raw` text when present.
pub fn program(
  program : Program,
  indent~ : String = "  ",
  line_end~ : String = "\n",
) -> String {
  let p = Printer::new(indent, line_end)
  for d in program.directives {
    p.directive(d)
    p.write(line_end)
  }
  for item in program.body {
    p.module_item(item)
    p.write(line_end)
  }
  p.to_string()
}

///|
/// Generates JavaScript source for a single statement.
pub fn statement(
  statement : Statement,
  indent~ : String = "  ",
  line_end~ : String = "\n",
) -> String {
  let p = Printer::new(indent, line_end)
  p.statement(statement)
  p.to_string()
}

///|
/// Generates JavaScript source for a single expression.
pub fn expression(
  expression : Expression,
  indent~ : String = "  ",
  line_end~ : String = "\n",
) -> String {
  let p = Printer::new(indent, line_end)
  p.expression(expression)
  p.to_string()
}

///|
fn Printer::module_item(self : Printer, item : ModuleItem) -> Unit {
  match item {
    Statement(s) => self.statement(s)
    Module(d) => self.module_declaration(d)
  }
}
