import gleam/bit_array
import gleam/bool
import gleam/bytes_tree
import gleam/erlang.{priv_directory}
import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None}
import gleam/otp/actor
import gleam/result
import gleam/string
import glisten.{Packet}
import simplifile

pub fn main() {
  let assert Ok(server) =
    glisten.handler(fn(_conn) { #(Nil, None) }, fn(msg, state, conn) {
      let assert Packet(msg) = msg

      let response = handle(msg)
      let result = case response {
        Ok(data) -> handle_success(data)
        Error(code) -> handle_error(code)
      }

      // our response needs to be  byte tree
      let assert Ok(_) = glisten.send(conn, bytes_tree.from_string(result))

      actor.continue(state)
    })
    // NOTE:  By default, `glisten` will listen on the loopback interface.  If
    // you want to listen on all interfaces, pass the following.  You can also
    // specify other interface values, including IPv6 addresses.
    |> glisten.bind("0.0.0.0")
    |> glisten.start_server(3000)
  // |> glisten.serve(3000)

  let assert Ok(info) = glisten.get_server_info(server, 3000)
  io.println(
    "Listening on "
    <> glisten.ip_address_to_string(info.ip_address)
    <> " at port "
    <> int.to_string(info.port),
  )

  process.sleep_forever()
}

type RequestData {
  RequestData(headers: List(String), method: String, path: String)
}

fn handle_error(code: Int) -> String {
  let err_line = case code {
    404 -> "HTTP/1.1 404 Not Found \r\n"
    403 -> "HTTP/1.1 403 Forbidden \r\n"
    _ -> "HTTP/1.1 500 Internal Server Error \r\n"
  }
  let err_html = "<html><body>" <> int.to_string(code) <> "</body></html>"
  err_line
  <> write_headers([
    "Content-Length: " <> int.to_string(string.byte_size(err_html)),
  ])
  <> err_html
}

fn handle_success(data: String) -> String {
  let res = "HTTP/1.1 200 OK \r\n"
  res
  <> write_headers(["Content-Length: " <> int.to_string(string.byte_size(data))])
  <> data
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

  use <- bool.guard(when: !validate_method(req_data.method), return: Error(403))
  let local_path = validate_path(req_data.path)
  use <- bool.guard(when: result.is_error(local_path), return: Error(404))
  let assert Ok(p) = local_path
  let data = simplifile.read(p)
  case data {
    Ok(d) -> Ok(d)
    Error(_) -> Error(500)
  }
}

fn validate_path(p: String) -> Result(String, Nil) {
  let priv = priv_directory("app")
  use <- bool.guard(when: result.is_error(priv), return: Error(Nil))
  let assert Ok(priv_path) = priv
  let local_path = {
    priv_path <> p
  }
  let is_file = result.unwrap(simplifile.is_file(local_path), False)
  let is_dir = result.unwrap(simplifile.is_directory(local_path), False)
  use <- bool.guard(when: is_file, return: Ok(local_path))
  case is_dir {
    False -> Error(Nil)
    True -> {
      let is_index_file_available =
        result.unwrap(simplifile.is_file(local_path <> "index.html"), False)
      case is_index_file_available {
        True -> Ok(local_path <> "index.html")
        False -> Error(Nil)
      }
    }
  }
}

fn write_headers(headers: List(String)) -> String {
  let output = string.join(headers, "\r\n")
  output <> "\r\n\r\n"
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
