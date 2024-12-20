import lustre/attribute.{class}
import lustre/element.{type Element, text}

import lustre/element/html.{div, h1}

pub fn root() -> Element(t) {
  div([class("app")], [
    h1([class("app-title")], [text("Gurl - The Gleam URL Shortener")]),
  ])
}
