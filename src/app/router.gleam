import app/components/layout
import app/context/ctx

import app/routes/home
import app/web
import gleam/http.{Get}

import lustre/element

import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: ctx.Context) -> Response {
  use req <- web.middleware(req, ctx)

  // Wisp doesn't have a special router abstraction, instead we recommend using
  // regular old pattern matching. This is faster than a router, is type safe,
  // and means you don't have to learn or be limited by a special DSL.
  //
  case wisp.path_segments(req) {
    // This matches `/`.
    [] -> home_page(req, ctx)

    // not sure I need these bits?
    ["internal-server-error"] -> wisp.internal_server_error()
    ["unprocessable-entity"] -> wisp.unprocessable_entity()
    ["method-not-allowed"] -> wisp.method_not_allowed([])
    ["entity-too-large"] -> wisp.entity_too_large()
    ["bad-request"] -> wisp.bad_request()

    // This matches all other paths.
    _ -> wisp.not_found()
  }
}

fn home_page(req: Request, _ctx: ctx.Context) -> Response {
  // The home page can only be accessed via GET requests, so this middleware is
  // used to return a 405: Method Not Allowed response for all other methods.
  use <- wisp.require_method(req, Get)
  let res =
    [home.root()]
    |> layout.layout
    |> element.to_document_string_builder

  wisp.ok()
  |> wisp.html_body(res)
}
