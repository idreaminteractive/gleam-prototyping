import gleam/int
import gleam/list

import gleam/string
import sqlc/lib/internal/sqlc

// TODO - setup glemplate to read + parse all the options
// TODO - build out using glemplate to send out to the text data 
// TODO - add in ability to handle `in` queries

// TODO - find out how to test generated code like this
// TODO - build out tests for this thing to validate output and details 
// TODO - other options for query cmds (exec result, etc)

pub fn build(sqlc: sqlc.SQLC) -> String {
  import_section() <> build_queries(sqlc.queries, "")
}

fn build_queries(queries: List(sqlc.Query), val: String) -> String {
  case queries {
    [] -> val
    [first, ..rest] -> build_queries(rest, build_query(first) <> val)
  }
}

fn import_section() -> String {
  "
import birl
import gleam/dynamic/decode
import gleam/option.{type Option}
import gleam/result

import sqlight


fn decode_birl_time_from_string() -> decode.Decoder(birl.Time) {
  decode.string
  |> decode.then(fn(v: String) {
    case birl.parse(v) {
      Ok(time) -> decode.success(time)
      Error(_err) -> decode.success(birl.now())
    }
  })
}

"
}

fn gleam_name_to_query_name(gname: String) -> String {
  // "example_name_thing" -> ExampleNameThing
  gname
  |> string.split("_")
  |> list.map(string.capitalise)
  |> string.join("")
}

fn query_name_to_gleam(qname: String) -> String {
  // GetUserById -> get_user_by_id
  // regardless of the query name, it needs to be snake case
  // if we find a capital, make it _<lower>
  qname
  |> string.to_utf_codepoints
  |> list.map(string.utf_codepoint_to_int)
  |> list.map(fn(x) {
    let assert Ok(codepoint) = string.utf_codepoint(x)
    let str_val = string.from_utf_codepoints([codepoint])
    case x {
      x if x >= 65 && x <= 90 -> {
        "_" <> string.lowercase(str_val)
      }
      _ -> str_val
    }
  })
  |> string.join("")
  |> fn(x) {
    let starts_with = string.starts_with(x, "_")
    case starts_with {
      True -> string.drop_start(x, 1)
      False -> x
    }
  }
}

fn build_query(query: sqlc.Query) -> String {
  let query_type_string = case query.cmd {
    sqlc.One ->
      build_query_output(
        query.text,
        query.name,
        query.columns,
        query.params,
        True,
      )
    sqlc.Many ->
      build_query_output(
        query.text,
        query.name,
        query.columns,
        query.params,
        False,
      )
    sqlc.Exec -> build_exec_output(query.text, query.name, query.params)
    _ -> ""
  }
  query_type_string
}

fn build_query_output(
  sql sql: String,
  name query_name: String,
  columns query_columns: List(sqlc.TableColumn),
  params params: List(sqlc.QueryParam),
  restrict_one single_result_only: Bool,
) {
  let out = "pub type " <> query_name <> " { 
    " <> query_name <> "(" <> string.join(
      ret_data_array_string(query_columns, []),
      ",",
    ) <> ")
  }
  
  fn " <> query_name_to_gleam(query_name) <> "_decoder() {
  " <> build_decoder_func(query_columns) <> "
  " <> build_decoder_success(query_name, query_columns) <> "
  }

  fn " <> query_name_to_gleam(query_name) <> "_sql() {
    \"" <> sql <> "\"
  }


pub fn " <> query_name_to_gleam(query_name) <> "(conn: sqlight.Connection, " <> build_query_fn_params(
      params,
    )
    |> string.join(",") <> ") {
  sqlight.query(
    " <> query_name_to_gleam(query_name) <> "_sql(),
    on: conn,
    with: [" <> build_query_sql_params(params) |> string.join(",") <> "],
    expecting: " <> query_name_to_gleam(query_name) <> "_decoder(),
  )
  " <> restrict_to_one_result(single_result_only) <> "
  
}
  "

  out
}

fn build_exec_output(
  sql sql: String,
  name query_name: String,
  params params: List(sqlc.QueryParam),
) {
  let out = "
  fn " <> query_name_to_gleam(query_name) <> "_sql() {
    \"" <> sql <> "\"
  }


pub fn " <> query_name_to_gleam(query_name) <> "(conn: sqlight.Connection, " <> build_query_fn_params(
      params,
    )
    |> string.join(",") <> ") {
  sqlight.exec(
    " <> query_name_to_gleam(query_name) <> "_sql(),
    on: conn
  )  
}
  "

  out
}

fn restrict_to_one_result(enforce: Bool) -> String {
  case enforce {
    True ->
      "|> result.try(fn(x) {
      case x {
        [val] -> Ok(val)
        [] -> Error(sqlight.SqlightError(sqlight.Notfound, \"No records found\", 0))
        _ -> Error(sqlight.SqlightError(sqlight.Mismatch, \"More than one record found\", 0))
      }
    })"
    False -> ""
  }
}

fn build_query_sql_params(params: List(sqlc.QueryParam)) -> List(String) {
  case params {
    [] -> []
    [first, ..rest] -> [
      param_type_to_sqlite_with(first.column.type_ref.name)
        <> "("
        <> first.column.name
        <> ")",
      ..build_query_sql_params(rest)
    ]
  }
}

fn build_query_fn_params(params: List(sqlc.QueryParam)) -> List(String) {
  case params {
    [] -> []
    [first, ..rest] -> [
      first.column.name
        <> " "
        <> first.column.name
        <> ": "
        <> sql_type_to_gleam(first.column.type_ref.name),
      ..build_query_fn_params(rest)
    ]
  }
}

fn build_decoder_func(query_columns: List(sqlc.TableColumn)) -> String {
  build_decoder_use_lines(query_columns, 0, [])
  |> list.reverse
  |> string.join("\n")
}

fn build_decoder_use_lines(
  fields: List(sqlc.TableColumn),
  id: Int,
  acc: List(String),
) {
  case fields {
    [] -> acc
    [first, ..rest] ->
      build_decoder_use_lines(rest, id + 1, [
        build_decoder_use_line(first, id),
        ..acc
      ])
  }
}

fn build_decoder_use_line(field: sqlc.TableColumn, id: Int) -> String {
  "use "
  <> field.name
  <> " <- decode.field("
  <> int.to_string(id)
  <> ", "
  <> sql_type_to_decoder_type(field.type_ref.name, !field.not_null)
  <> ")"
}

fn build_decoder_success(
  query_name: String,
  query_columns: List(sqlc.TableColumn),
) {
  "decode.success("
  <> query_name
  <> "("
  <> build_decoder_success_params(query_columns) |> string.join(",")
  <> "))"
}

fn build_decoder_success_params(
  query_columns: List(sqlc.TableColumn),
) -> List(String) {
  case query_columns {
    [] -> []
    [first, ..rest] -> [first.name <> ":", ..build_decoder_success_params(rest)]
  }
}

fn ret_data_array_string(
  query_columns: List(sqlc.TableColumn),
  output: List(String),
) {
  case query_columns {
    [] -> output
    [first, ..rest] -> {
      case first.not_null {
        True -> [
          first.name <> ": " <> sql_type_to_gleam(first.type_ref.name),
          ..ret_data_array_string(rest, output)
        ]
        False -> [
          first.name
            <> ": Option("
            <> sql_type_to_gleam(first.type_ref.name)
            <> ")",
          ..ret_data_array_string(rest, output)
        ]
      }
    }
  }
}

fn sql_type_to_gleam(t: String) -> String {
  case string.lowercase(t) {
    "boolean" -> "Bool"
    "integer" -> "Int"
    "varchar" <> _ -> "String"
    "timestamp" -> "birl.Time"
    _ -> "unknown"
  }
}

fn sql_type_to_decoder_type(t: String, optional: Bool) -> String {
  case string.lowercase(t), optional {
    "boolean", True -> "decode.optional(sqlight.decode_bool())"
    "boolean", False -> "sqlight.decode_bool()"
    "integer", True -> "decode.optional(decode.int)"
    "integer", False -> "decode.int"
    "varchar" <> _, True -> "decode.optional(decode.string)"
    "varchar" <> _, False -> "decode.string"
    // we don't handle optional timestmaps yet
    "timestamp", _ -> "decode_birl_time_from_string()"

    _, _ -> "unknown"
  }
}

fn param_type_to_sqlite_with(t: String) -> String {
  case string.lowercase(t) {
    "boolean" -> "sqlight.bool"
    "integer" -> "sqlight.int"
    "varchar" <> _ -> "sqlight.text"
    _ -> "unknown"
  }
}
