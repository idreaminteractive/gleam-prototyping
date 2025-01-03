//// This module decodes the JSON generated by sqlc
////

import gleam/dynamic
import gleam/dynamic/decode
import gleam/option.{type Option}

pub type TypeRef {
  TypeRef(catalog: String, schema: String, name: String)
}

pub type TableColumn {
  TableColumn(
    name: String,
    not_null: Bool,
    is_array: Bool,
    comment: String,
    length: Int,
    is_named_param: Bool,
    is_func_call: Bool,
    scope: String,
    table_alias: String,
    is_sqlc_slice: Bool,
    original_name: String,
    unsigned: Bool,
    array_dims: Int,
    table: Option(TableRef),
    type_ref: TypeRef,
  )
}

pub type TableRef {
  TableRef(catalog: String, schema: String, name: String)
}

pub type Table {
  Table(rel: TableRef, comment: String, columns: List(TableColumn))
}

pub type Schema {
  Schema(comment: String, name: String, tables: List(Table))
}

pub type Catalog {
  Catalog(
    comment: String,
    default_schema: String,
    name: String,
    schemas: List(Schema),
  )
}

pub type QueryCmd {
  One
  Many
  Exec
  ExecResult
  Unknown
}

pub type QueryParam {
  QueryParam(number: Int, column: TableColumn)
}

pub type Query {
  Query(
    text: String,
    name: String,
    cmd: QueryCmd,
    filename: String,
    columns: List(TableColumn),
    insert_into_table: Option(TableRef),
    comments: List(String),
    params: List(QueryParam),
  )
}

pub type SQLC {
  SQLC(
    sqlc_version: String,
    plugin_options: String,
    global_options: String,
    catalog: Catalog,
    queries: List(Query),
  )
}

pub fn decode_sqlc(data: dynamic.Dynamic) {
  let table_ref_decoder = {
    use catalog <- decode.field("catalog", decode.string)
    use schema <- decode.field("schema", decode.string)
    use name <- decode.field("name", decode.string)
    decode.success(TableRef(catalog, schema, name))
  }

  let type_ref_decoder = {
    use catalog <- decode.field("catalog", decode.string)
    use schema <- decode.field("schema", decode.string)
    use name <- decode.field("name", decode.string)
    decode.success(TypeRef(catalog, schema, name))
  }

  let table_col_decoder = {
    use name <- decode.field("name", decode.string)
    use not_null <- decode.field("not_null", decode.bool)
    use is_array <- decode.field("is_array", decode.bool)
    use comment <- decode.field("comment", decode.string)
    use length <- decode.field("length", decode.int)
    use is_named_param <- decode.field("is_named_param", decode.bool)
    use is_func_call <- decode.field("is_func_call", decode.bool)
    use scope <- decode.field("scope", decode.string)
    use table_alias <- decode.field("table_alias", decode.string)
    use is_sqlc_slice <- decode.field("is_sqlc_slice", decode.bool)
    use original_name <- decode.field("original_name", decode.string)
    use unsigned <- decode.field("unsigned", decode.bool)
    use array_dims <- decode.field("array_dims", decode.int)
    use table <- decode.field("table", decode.optional(table_ref_decoder))
    use type_ref <- decode.field("type", type_ref_decoder)

    decode.success(TableColumn(
      name,
      not_null,
      is_array,
      comment,
      length,
      is_named_param,
      is_func_call,
      scope,
      table_alias,
      is_sqlc_slice,
      original_name,
      unsigned,
      array_dims,
      table,
      type_ref,
    ))
  }

  let table_decoder = {
    use rel <- decode.field("rel", table_ref_decoder)
    use comment <- decode.field("comment", decode.string)
    use columns <- decode.field("columns", decode.list(table_col_decoder))
    decode.success(Table(rel, comment, columns))
  }

  let schema_decoder = {
    use comment <- decode.field("comment", decode.string)
    use name <- decode.field("name", decode.string)
    use tables <- decode.field("tables", decode.list(table_decoder))
    decode.success(Schema(comment:, name:, tables:))
  }

  let catalog_decoder = {
    use comment <- decode.field("comment", decode.string)
    use default_schema <- decode.field("default_schema", decode.string)
    use name <- decode.field("name", decode.string)
    use schemas <- decode.field("schemas", decode.list(schema_decoder))
    decode.success(Catalog(comment, default_schema, name, schemas))
  }

  let params_decoder = {
    use number <- decode.field("number", decode.int)
    use column <- decode.field("column", table_col_decoder)

    decode.success(QueryParam(number, column))
  }
  let cmd_decoder =
    decode.string
    |> decode.then(fn(cmd) {
      case cmd {
        ":one" -> decode.success(One)
        ":many" -> decode.success(Many)
        ":exec" -> decode.success(ExecResult)
        ":execresult" -> decode.success(ExecResult)
        _ -> decode.failure(Unknown, "Failed")
      }
    })

  let query_decoder = {
    use text <- decode.field("text", decode.string)
    use name <- decode.field("name", decode.string)
    use cmd <- decode.field("cmd", cmd_decoder)
    use filename <- decode.field("filename", decode.string)
    use columns <- decode.field("columns", decode.list(table_col_decoder))
    use insert_into_table <- decode.field(
      "insert_into_table",
      decode.optional(table_ref_decoder),
    )
    use comments <- decode.field("comments", decode.list(decode.string))
    use params <- decode.field("params", decode.list(params_decoder))
    decode.success(Query(
      text,
      name,
      cmd,
      filename,
      columns,
      insert_into_table,
      comments,
      params,
    ))
  }

  let decoder = {
    use sqlc_version <- decode.field("sqlc_version", decode.string)
    use plugin_options <- decode.field("plugin_options", decode.string)
    use global_options <- decode.field("global_options", decode.string)
    use catalog <- decode.field("catalog", catalog_decoder)
    use queries <- decode.field("queries", decode.list(query_decoder))

    decode.success(SQLC(
      sqlc_version,
      plugin_options,
      global_options,
      catalog,
      queries,
    ))
  }

  decode.run(data, decoder)
}
