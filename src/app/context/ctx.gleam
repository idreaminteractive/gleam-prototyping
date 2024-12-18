import app/models/item.{type Item}

pub type Context {
  Context(static_directory: String, items: List(Item))
}
