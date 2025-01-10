import gleam/int
import gleam/io
import gleam/list
import justin

import gleam/string
import gleam/string_tree
import sqlc/lib/internal/sqlc
import sqlc/lib/internal/templates
import sqlc/lib/internal/type_convert

// DONE - I've concluded templating engines stink
// TODO - finish reorg of templating out the strings
// TODO - add in ability to handle `in` queries

// TODO - find out how to test generated code like this
// TODO - build out tests for this thing to validate output and details 
// TODO - other options for query cmds (exec result, etc)

pub fn build(sqlc_object: sqlc.SQLC) -> String {
  let tree = string_tree.new()
  // add imports (may want to conditionally add or remove bits)
  string_tree.append(tree, templates.import_section())
  // add stuff generated from queries.
  string_tree.append(tree, build_queries(sqlc_object.queries, ""))
  string_tree.to_string(tree)
}

fn build_queries(queries: List(sqlc.Query), val: String) -> String {
  case queries {
    [] -> val
    [first, ..rest] -> build_queries(rest, build_query(first) <> val)
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
    // what else is here?
    _ -> {
      // debugging for now.
      let _ = "Missing... command " <> string.inspect(query.cmd) |> io.debug
      ""
    }
  }
  query_type_string
}

// move into templatings.
fn build_query_output(
  sql sql: String,
  name query_name: String,
  columns query_columns: List(sqlc.TableColumn),
  params params: List(sqlc.QueryParam),
  restrict_one single_result_only: Bool,
) {
  templates.add_type_def_for_query(
    query_name,
    generate_type_params_from_return_columns(query_columns, []),
  )
  <> templates.add_sql_decoder_fn(
    query_name,
    build_decoder_func(query_columns),
    build_decoder_success(query_name, query_columns),
  )
  <> templates.add_sql_string_fn(query_name, sql)
  <> templates.add_sqlight_call(
    query_name,
    build_sqlight_query_fn_params(params),
    single_result_only,
  )
}

fn build_exec_output(
  sql sql: String,
  name query_name: String,
  params params: List(sqlc.QueryParam),
) {
  let out = "
  fn " <> justin.snake_case(query_name) <> "_sql() {
    \"" <> sql <> "\"
  }


pub fn " <> justin.snake_case(query_name) <> "(conn: sqlight.Connection, " <> build_sqlight_query_fn_params(
      params,
    )
    |> string.join(",") <> ") {
  sqlight.exec(
    " <> justin.snake_case(query_name) <> "_sql(),
    on: conn
  )  
}
  "

  out
}

fn build_query_sql_params(params: List(sqlc.QueryParam)) -> List(String) {
  case params {
    [] -> []
    [first, ..rest] -> [
      type_convert.param_type_to_sqlite_with(first.column.type_ref.name)
        <> "("
        <> first.column.name
        <> ")",
      ..build_query_sql_params(rest)
    ]
  }
}

fn build_sqlight_query_fn_params(params: List(sqlc.QueryParam)) -> List(String) {
  case params {
    [] -> []
    [first, ..rest] -> [
      first.column.name
        <> " "
        <> first.column.name
        <> ": "
        <> type_convert.sql_type_to_gleam(first.column.type_ref.name),
      ..build_sqlight_query_fn_params(rest)
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
  <> type_convert.sql_type_to_decoder_type(field.type_ref.name, !field.not_null)
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

fn generate_type_params_from_return_columns(
  query_columns: List(sqlc.TableColumn),
  output: List(String),
) {
  case query_columns {
    [] -> output
    [first, ..rest] -> {
      case first.not_null {
        True -> [
          first.name
            <> ": "
            <> type_convert.sql_type_to_gleam(first.type_ref.name),
          ..generate_type_params_from_return_columns(rest, output)
        ]
        False -> [
          first.name
            <> ": Option("
            <> type_convert.sql_type_to_gleam(first.type_ref.name)
            <> ")",
          ..generate_type_params_from_return_columns(rest, output)
        ]
      }
    }
  }
}
