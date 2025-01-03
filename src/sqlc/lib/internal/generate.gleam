import gleam/string
import sqlc/lib/internal/lib
import sqlc/lib/internal/project

pub fn comment_dont_edit() {
  let assert Ok(version) = project.version()
  "
  //// Code generated by sqlc_gen_gleam. DO NOT EDIT.
  //// versions:
  ////   sqlc_gen_gleam v{version}
  ////
  "
  |> string.replace("{version}", version)
  |> lib.dedent
}