///|
using @estree {
  type AccessorProperty,
  type Argument,
  type CallExpression,
  type Class,
  type ClassElement,
  type Decorator,
  type Declaration,
  type Directive,
  type ExportDefaultKind,
  type Expression,
  type ExpressionOrSuper,
  type ForInLeft,
  type Function,
  type FunctionBody,
  type Identifier,
  type ImportAttribute,
  type Literal,
  type MemberExpression,
  type MethodDefinition,
  type ModuleDeclaration,
  type ModuleExportName,
  type ModuleItem,
  type ObjectMember,
  type Pattern,
  type Program,
  type Property,
  type PropertyDefinition,
  type PropertyKey,
  type Statement,
  type TemplateLiteral,
  type VariableDeclaration,
}

///|
/// Output buffer plus indentation state, mirroring astring's `State`.
priv struct Printer {
  out : StringBuilder
  indent : String
  line_end : String
  mut level : Int32
}

///|
fn Printer::new(indent : String, line_end : String) -> Printer {
  { out: StringBuilder(), indent, line_end, level: 0, }
}

///|
fn Printer::write(self : Printer, text : String) -> Unit {
  self.out.write_string(text)
}

///|
/// The indentation string for `level`.
fn Printer::indentation(self : Printer, level : Int32) -> String {
  let buf = StringBuilder()
  for _ in 0..<level {
    buf.write_string(self.indent)
  }
  buf.to_string()
}

///|
/// Writes `{`, then `count` items each on its own indented line, then `}`.
/// Shared by blocks, function bodies, class bodies and static blocks.
fn Printer::braced(
  self : Printer,
  count : Int32,
  item : (Int32) -> Unit,
) -> Unit {
  let indent = self.indentation(self.level)
  self.level += 1
  self.write("{")
  if count > 0 {
    self.write(self.line_end)
    let item_indent = indent + self.indent
    for i in 0..<count {
      self.write(item_indent)
      item(i)
      self.write(self.line_end)
    }
    self.write(indent)
  }
  self.write("}")
  self.level -= 1
}

///|
/// Writes `items` separated by `, `.
fn[T] Printer::comma_separated(
  self : Printer,
  items : ArrayView[T],
  item : (T) -> Unit,
) -> Unit {
  for i, x in items {
    if i > 0 {
      self.write(", ")
    }
    item(x)
  }
}

///|
/// Writes `(items)`; astring's `formatSequence`.
fn[T] Printer::sequence(
  self : Printer,
  items : ArrayView[T],
  item : (T) -> Unit,
) -> Unit {
  self.write("(")
  self.comma_separated(items, item)
  self.write(")")
}

///|
fn Printer::to_string(self : Printer) -> String {
  self.out.to_string()
}
