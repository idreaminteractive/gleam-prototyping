import gleam/string

pub fn sql_type_to_gleam(t: String) -> String {
  case string.lowercase(t) {
    "boolean" -> "Bool"
    "integer" -> "Int"
    "varchar" <> _ -> "String"
    "timestamp" -> "birl.Time"
    _ -> "unknown"
  }
}

pub fn sql_type_to_decoder_type(t: String, optional: Bool) -> String {
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

pub fn param_type_to_sqlite_with(t: String) -> String {
  case string.lowercase(t) {
    "boolean" -> "sqlight.bool"
    "integer" -> "sqlight.int"
    "varchar" <> _ -> "sqlight.text"
    _ -> "unknown"
  }
}
