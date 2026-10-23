///|
/// `gen <in_dir> <out_dir>`: decodes every `<name>.json` ESTree program in
/// `in_dir` and writes the generated JavaScript to `<out_dir>/<name>.js`.
/// Failures are reported on stdout as `error <name>: <reason>`.
fn main {
  guard @env.args() is [_, in_dir, out_dir, ..] else {
    println("usage: gen <in_dir> <out_dir>")
    return
  }
  let names = @fs.read_dir(in_dir) catch {
    err => {
      println("error \{in_dir}: \{(err : Error)}")
      return
    }
  }
  for name in names {
    guard name.strip_suffix(".json") is Some(stem) else { continue }
    generate("\{in_dir}/\{name}", "\{out_dir}/\{stem}.js") catch {
      err => println("error \{name}: \{err}")
    }
  }
}

///|
fn generate(input : String, output : String) -> Unit raise {
  let program = @estree.Program::parse_json(@fs.read_file_to_string(input))
  @fs.write_string_to_file(output, @codegen.program(program))
}
