import gleam/list
import gleam/set.{type Set}
import gleam/string

pub fn new_collection(card: String) -> Set(String) {
  set.new() |> set.insert(card)
}

pub fn add_card(collection: Set(String), card: String) -> #(Bool, Set(String)) {
  #(set.contains(collection, card), set.insert(collection, card))
}

pub fn trade_card(
  my_card: String,
  their_card: String,
  collection: Set(String),
) -> #(Bool, Set(String)) {
  case set.contains(collection, my_card) {
    False -> #(False, set.insert(collection, their_card))
    True ->
      fn() {
        case set.contains(collection, their_card) {
          False -> #(
            True,
            set.delete(collection, my_card) |> set.insert(their_card),
          )
          //   still trade ours?
          True -> #(False, set.delete(collection, my_card))
        }
      }()
  }
}

pub fn boring_cards(collections: List(Set(String))) -> List(String) {
  list.fold(collections, [], fn(l, s) {
    set.from_list(l)
    |> set.intersection(s)
    |> set.to_list
  })
  |> list.sort(string.compare)
}

pub fn total_cards(collections: List(Set(String))) -> Int {
  list.fold(collections, [], fn(l, s) {
    set.from_list(l)
    |> set.union(s)
    |> set.to_list
  })
  |> list.length
}

pub fn shiny_cards(collection: Set(String)) -> Set(String) {
  set.filter(collection, fn(s) { string.starts_with(s, "Shiny ") })
}
