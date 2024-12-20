import gleam/bit_array
import gleam/dict
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import wisp.{type Request, type Response}

pub fn basic_auth_handler(
  req: Request,
  username: String,
  password: String,
  handler: fn() -> Response,
) -> Response {
  let response = handler()
  let hashed =
    extract_basic_auth_from_headers(req.headers)
    |> validate_basic_auth(username, password)

  //   nothing found 
  case hashed {
    False ->
      wisp.response(401)
      |> wisp.set_header(
        "WWW-Authenticate",
        "Basic realm=\"restricted\", charset=\"UTF-8\"",
      )
    //   found it! 
    True -> response
  }
}

fn validate_basic_auth(
  auth_header: String,
  username: String,
  password: String,
) -> Bool {
  let basic_val =
    auth_header
    |> string.split_once(on: " ")
    |> fn(x) {
      case x {
        Ok(v) -> v.1
        Error(_) -> ""
      }
    }
    |> io.debug

  basic_val
  |> bit_array.base64_decode
  |> fn(x) {
    case x {
      Ok(ba) -> ba
      _ -> bit_array.from_string("")
    }
  }
  |> io.debug
  False
}

fn extract_basic_auth_from_headers(headers: List(#(String, String))) -> String {
  headers
  |> io.debug
  |> list.find(fn(x) {
    case x {
      #("authorization", _) -> True
      _ -> False
    }
  })
  |> result.unwrap(#("", ""))
  |> fn(x) { x.1 }
}
