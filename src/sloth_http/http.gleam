import gleam/bit_array
import gleam/bool
import gleam/bytes_tree
import gleam/erlang.{priv_directory}
import gleam/erlang/process
import gleam/io
import gleam/list
import gleam/option.{None}
import gleam/otp/actor
import gleam/result
import gleam/string
import glisten.{Packet}
import simplifile

pub fn main() {
  let assert Ok(_) =
    glisten.handler(fn(_conn) { #(Nil, None) }, fn(msg, state, conn) {
      let assert Packet(msg) = msg

      let assert Ok(response) = handle(msg)
      // our response needs to be  byte tree
      let assert Ok(_) = glisten.send(conn, bytes_tree.from_string(response))
      actor.continue(state)
    })
    // NOTE:  By default, `glisten` will listen on the loopback interface.  If
    // you want to listen on all interfaces, pass the following.  You can also
    // specify other interface values, including IPv6 addresses.
    |> glisten.bind("0.0.0.0")
    |> glisten.serve(3000)

  process.sleep_forever()
}

type RequestData {
  RequestData(headers: List(String), method: String, path: String)
}

fn parse_request(msg: BitArray) -> Result(RequestData, Nil) {
  use str <- result.try(bit_array.to_string(msg))
  let split = string.split(str, on: "\r\n")
  use request_line <- result.try(list.first(split))
  let rest_line = string.split(request_line, " ")
  use #(method, path) <- result.try(case rest_line {
    [m, p, ..] -> Ok(#(m, p))
    _ -> Error(Nil)
  })

  use rest <- result.try(list.rest(split))
  let headers =
    list.fold_until(from: [], over: rest, with: fn(acc, value) {
      case value {
        "" -> list.Stop(acc)
        _ -> list.Continue([value, ..acc])
      }
    })
    |> list.reverse
    |> io.debug

  Ok(RequestData(headers:, method:, path:))
}

fn handle(msg: BitArray) -> Result(String, Int) {
  let req_data = parse_request(msg)
  case req_data {
    Error(Nil) -> Error(500)
    Ok(d) -> handle_request(d)
  }
}

fn handle_request(req_data: RequestData) -> Result(String, Int) {
  // valid request. let's verify method
  req_data |> io.debug
  use <- bool.guard(when: !validate_method(req_data.method), return: Error(403))
  use <- bool.guard(when: !validate_path(req_data.path), return: Error(404))
  Ok("hello")
}

fn validate_path(p: String) -> Bool {
  let priv = priv_directory("app")
  use <- bool.guard(when: result.is_error(priv), return: False)
  // this will never fail here. :D
  let assert Ok(priv_path) = priv
  let local_path = { priv_path <> p } |> io.debug
  let is_file = result.unwrap(simplifile.is_file(local_path), False)
  let is_dir = result.unwrap(simplifile.is_directory(local_path), False)
  use <- bool.guard(when: is_file, return: True)
  case is_dir {
    True -> result.unwrap(simplifile.is_file(local_path <> "index.html"), False)
    False -> False
  }
}

fn validate_method(m: String) -> Bool {
  case m {
    "GET" | "HEAD" -> True
    _ -> False
  }
}

fn handle_get() {
  todo
}

fn handle_head() {
  todo
}
