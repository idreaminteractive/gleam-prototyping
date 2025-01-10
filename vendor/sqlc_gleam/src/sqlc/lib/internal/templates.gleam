import gleam/string
import gleam/string_tree
import justin

pub fn import_section() -> String {
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

pub fn add_type_def_for_query(
  query_name: String,
  record_attributes: List(String),
) -> String {
  "pub type "
  <> query_name
  <> " {"
  <> query_name
  <> "("
  <> record_attributes |> string.join(",")
  <> ")"
  <> "}"
}

pub fn add_sql_decoder_fn(
  query_name: String,
  decoder_func_body: String,
  decoder_func_success_line: String,
) -> String {
  "fn "
  <> justin.snake_case(query_name)
  <> "_decoder() { "
  <> decoder_func_body
  <> decoder_func_success_line
  <> "}"
}
