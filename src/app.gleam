import app/chat_actor/chat.{handle_message}
import app/context/ctx
import app/router
import gleam/dynamic
import gleam/erlang/process
import gleam/otp/actor
import mist

import sqlight
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)

  let assert Ok(my_actor) = actor.start([], handle_message)
  let ctx = ctx.Context(static_directory: static_directory(), subject: my_actor)
  let handler = router.handle_request(_, ctx)

  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    // this line is importante
    |> mist.bind("0.0.0.0")
    |> mist.port(8080)
    |> mist.start_http

  process.sleep_forever()
}

pub fn static_directory() -> String {
  // The priv directory is where we store non-Gleam and non-Erlang files,
  // including static assets to be served.
  // This function returns an absolute path and works both in development and in
  // production after compilation.
  let assert Ok(priv_directory) = wisp.priv_directory("app")
  priv_directory <> "/static"
}
