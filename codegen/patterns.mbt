///|
fn Printer::pattern(self : Printer, p : Pattern) -> Unit {
  match p {
    Identifier(id) => self.identifier(id)
    Member(m) => self.member_expression(m)
    Object(o) => {
      self.write("{")
      self.comma_separated(o.properties, item => {
        match item {
          Property(property) => {
            if !property.is_shorthand {
              self.property_key(property.key)
              self.write(": ")
            }
            self.pattern(property.value)
          }
          Rest(rest) => {
            self.write("...")
            self.pattern(rest.argument)
          }
        }
      })
      self.write("}")
    }
    Array(a) => self.array(a.elements, p => self.pattern(p))
    Rest(r) => {
      self.write("...")
      self.pattern(r.argument)
    }
    Assignment(a) => {
      self.pattern(a.left)
      self.write(" = ")
      self.expression(a.right)
    }
  }
}
