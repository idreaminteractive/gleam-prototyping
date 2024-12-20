import lustre/attribute.{autofocus, class, name, placeholder}
import lustre/element.{type Element, text}

import lustre/element/html.{button, div, form, h1, input, span, svg}

pub fn root() -> Element(t) {
  div([class("app")], [
    h1([class("app-title")], [text("Gurl - The Gleam URL Shortener")]),
  ])
}
