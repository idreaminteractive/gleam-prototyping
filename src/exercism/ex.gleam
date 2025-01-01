// Please define the TreasureChest type

import gleam/string

pub opaque type TreasureChest(a) {

  TreasureChest(treasure: a, password: String)
}

pub fn create(
  password: String,
  contents: treasure,
) -> Result(TreasureChest(treasure), String) {
  let l = string.length(password)
  case l {
    _ if l < 8 -> Error("Password must be at least 8 characters long")
    _ -> Ok(TreasureChest(password:, treasure: contents))
  }
}

pub fn open(
  chest: TreasureChest(treasure),
  password: String,
) -> Result(treasure, String) {
  case chest {
    TreasureChest(password: password, treasure: t) -> Ok(t)
    _ -> Error("Incorrect password")
  }
}
