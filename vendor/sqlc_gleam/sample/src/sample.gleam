import gleam/io
import sqlight

pub fn main() {
  io.println("Hello from sample!")

  use conn <- sqlight.with_connection("data/sqlite.db")
  todo
}
