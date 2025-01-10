import gleam/io
import sqlc/sqlc

import gleam/dict
import glemplate/assigns
import glemplate/html
import glemplate/parser

pub fn main() {
  let template = "<b>Welcome, <%= name %>!</b>"
  let p = parser.new()
  let assert Ok(tpl) = parser.parse_to_template(template, "input.html.glemp", p)
  let assigns = assigns.from_list([#("name", assigns.String("<Nicd>"))])
  let template_cache = dict.new()
  let assert Ok(val) = html.render(tpl, assigns, template_cache)
  val |> io.debug
  // "<b>Welcome, &lt;Nicd&gt;!</b>"

  sqlc.run_codegen()
}
