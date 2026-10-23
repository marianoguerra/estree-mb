///|
fn Printer::module_declaration(self : Printer, d : ModuleDeclaration) -> Unit {
  match d {
    Import(x) => {
      self.write("import ")
      if x.phase is Some(phase) {
        self.write("\{phase.to_string()} ")
      }
      if !x.specifiers.is_empty() {
        let named = x.specifiers.filter(s => s is Named(_))
        let leading = x.specifiers.filter(s => !(s is Named(_)))
        self.comma_separated(leading, s => {
          match s {
            Default(d) => self.identifier(d.local_)
            Namespace(n) => {
              self.write("* as ")
              self.identifier(n.local_)
            }
            Named(_) => ()
          }
        })
        if !named.is_empty() {
          if !leading.is_empty() {
            self.write(", ")
          }
          self.write("{")
          self.comma_separated(named, s => {
            guard s is Named(spec) else { return }
            self.module_export_name(spec.imported)
            if !same_name(spec.imported, Identifier(spec.local_)) {
              self.write(" as ")
              self.identifier(spec.local_)
            }
          })
          self.write("}")
        }
        self.write(" from ")
      }
      self.literal(x.source)
      self.attributes(x.attributes)
      self.write(";")
    }
    ExportNamed(x) => {
      self.write("export ")
      match x.declaration {
        Some(declaration) => self.declaration(declaration)
        None => {
          self.write("{")
          self.comma_separated(x.specifiers, spec => {
            self.module_export_name(spec.local_)
            if !same_name(spec.local_, spec.exported) {
              self.write(" as ")
              self.module_export_name(spec.exported)
            }
          })
          self.write("}")
          if x.source is Some(source) {
            self.write(" from ")
            self.literal(source)
          }
          self.attributes(x.attributes)
          self.write(";")
        }
      }
    }
    ExportDefault(x) => {
      self.write("export default ")
      self.export_default(x.declaration)
    }
    ExportAll(x) => {
      self.write("export * ")
      if x.exported is Some(exported) {
        self.write("as ")
        self.module_export_name(exported)
        self.write(" ")
      }
      self.write("from ")
      self.literal(x.source)
      self.attributes(x.attributes)
      self.write(";")
    }
  }
}

///|
fn Printer::export_default(self : Printer, d : ExportDefaultKind) -> Unit {
  match d {
    Function(f) => self.function(f)
    Class(c) => self.class(c)
    // Unlike astring, a bare function or class *expression* is parenthesized
    // so that it does not reparse as a declaration.
    Expression(Function(_) | Class(_) as e) => {
      self.parenthesized(e)
      self.write(";")
    }
    Expression(e) => {
      self.expression(e)
      if in_precedence_table(e) {
        self.write(";")
      }
    }
  }
}

///|
/// Writes ` with { key: "value", ... }` when there are attributes.
fn Printer::attributes(
  self : Printer,
  attributes : Array[ImportAttribute],
) -> Unit {
  if attributes.is_empty() {
    return
  }
  self.write(" with { ")
  self.comma_separated(attributes, a => {
    self.module_export_name(a.key)
    self.write(": ")
    self.literal(a.value)
  })
  self.write(" }")
}

///|
/// Writes an identifier name or (ES2022) a string literal name.
fn Printer::module_export_name(self : Printer, name : ModuleExportName) -> Unit {
  match name {
    Identifier(id) => self.identifier(id)
    Literal(l) => self.literal(l)
  }
}

///|
/// Whether `a as b` can be written as just `a`.
fn same_name(a : ModuleExportName, b : ModuleExportName) -> Bool {
  match (a, b) {
    (Identifier(x), Identifier(y)) => x.name == y.name
    (Literal(x), Literal(y)) => x.value == y.value
    _ => false
  }
}
