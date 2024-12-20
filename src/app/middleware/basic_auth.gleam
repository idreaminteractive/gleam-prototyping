import gleam/bit_array
import gleam/bool
import gleam/dict
import gleam/io
import gleam/list
import gleam/option
import gleam/pair
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
    //   found it + it matches
    True -> response
  }
}

fn validate_basic_auth(
  auth_header: String,
  username: String,
  password: String,
) -> Bool {
  // hmm,.
  auth_header
  |> result.try(string.split_once(_, on: " "))
  |> result.unwrap(#("", ""))
  |> pair.first
  // |> result.try(fn(x) {
  //   case x {
  //     Ok(v) -> v.1
  //     Error(_) -> ""
  //   }
  // })
  |> io.debug
  // ok - so we got the thing 

  // let success =
  //   basic_val
  //   |> bit_array.base64_decode
  //   |> fn(x) {
  //     case x {
  //       Ok(ba) -> ba
  //       _ -> bit_array.from_string("")
  //     }
  //   }
  //   |> string.split_once(on: ":")
  //   |> io.debug
  //   |> fn(x) {
  //     case x {

  //     }
  //   }

  False
}

fn extract_basic_auth_from_headers(headers: List(#(String, String))) -> String {
  headers
  |> list.key_find("authorization")
  |> result.unwrap("")
}
