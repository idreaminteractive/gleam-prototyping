import gleam/dynamic as d
import gleam/json

import simplifile
import sqlc/lib/config
import sqlc/lib/internal/build
import sqlc/lib/internal/generate
import sqlc/lib/internal/lib
import sqlc/lib/internal/sqlc

// we'll use our code gen files as the source + build out what we need to do here 
pub fn run_codegen() {
  let codegen_path = "gen/codegen.json"
  let assert Ok(True) = simplifile.is_file(codegen_path)
  //   ok - it's a path. let's go 
  // let's create our generated folder under src
  let conf =
    config.Config(
      json_file_path: "gen/codegen.json",
      gleam_module_out_path: "gen/sqlc_sqlite.gleam",
    )
  use json_string <- lib.try_nil(config.get_json_file(conf))

  use dyn_json <- lib.try_nil(json.decode(from: json_string, using: d.dynamic))

  let assert Ok(parsed) = sqlc.decode_sqlc(dyn_json)

  let assert Ok(_) =
    config.get_module_directory(conf)
    |> simplifile.create_directory_all()

  let assert Ok(_) =
    simplifile.write(
      to: config.get_module_path(conf),
      contents: generate.comment_dont_edit() <> build.build(parsed),
    )

  Ok(Nil)
}
