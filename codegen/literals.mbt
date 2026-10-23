///|
fn Printer::identifier(self : Printer, id : Identifier) -> Unit {
  self.write(id.name)
}

///|
/// Writes a literal: its `raw` text when present (as astring does), otherwise
/// a canonical rendering of its value.
fn Printer::literal(self : Printer, literal : Literal) -> Unit {
  if literal.raw is Some(raw) {
    self.write(raw)
    return
  }
  match literal.value {
    String(s) => self.write(quote_string(s))
    Boolean(b) => self.write(if b { "true" } else { "false" })
    Null => self.write("null")
    // `Double::to_string` agrees with JavaScript's `Number::toString`.
    Number(n) => self.write(n.to_string())
    RegExp(pattern~, flags~) => self.write("/\{pattern}/\{flags}")
    BigInt(digits) => self.write("\{digits}n")
  }
}

///|
/// Quotes a string like JavaScript's `JSON.stringify`.
fn quote_string(s : String) -> String {
  let buf = StringBuilder()
  buf.write_char('"')
  // Unescaped runs are copied as raw code units so surrogate pairs survive.
  let mut run_start = 0
  for i in 0..<s.length() {
    let unit = s.code_unit_at(i).to_int()
    let escape = match unit {
      0x22 => "\\\""
      0x5C => "\\\\"
      0x08 => "\\b"
      0x0C => "\\f"
      0x0A => "\\n"
      0x0D => "\\r"
      0x09 => "\\t"
      _ if unit < 0x20 || is_lone_surrogate(s, i) => "\\u\{hex4(unit)}"
      _ => continue
    }
    buf.write_substring(s, run_start, i - run_start)
    buf.write_string(escape)
    run_start = i + 1
  }
  buf.write_substring(s, run_start, s.length() - run_start)
  buf.write_char('"')
  buf.to_string()
}

///|
fn is_lone_surrogate(s : String, i : Int32) -> Bool {
  let unit = s.code_unit_at(i).to_int()
  if unit >= 0xD800 && unit <= 0xDBFF {
    !(i + 1 < s.length() && s.code_unit_at(i + 1).to_int() is (0xDC00..<=0xDFFF))
  } else if unit >= 0xDC00 && unit <= 0xDFFF {
    !(i > 0 && s.code_unit_at(i - 1).to_int() is (0xD800..<=0xDBFF))
  } else {
    false
  }
}

///|
fn hex4(n : Int32) -> String {
  let digits = "0123456789abcdef"
  let buf = StringBuilder()
  for shift in [12, 8, 4, 0] {
    buf.write_char(digits.get_char((n >> shift) & 0xF).unwrap())
  }
  buf.to_string()
}
