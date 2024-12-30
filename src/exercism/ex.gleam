import gleam/list

pub fn place_location_to_treasure_location(
  place_location: #(String, Int),
) -> #(Int, String) {
  let #(x, s) = place_location
  #(s, x)
}

pub fn treasure_location_matches_place_location(
  place_location: #(String, Int),
  treasure_location: #(Int, String),
) -> Bool {
  treasure_location == place_location_to_treasure_location(place_location)
}

// Implement the count_place_treasures function, that takes a place 
// (such as #("Aqua Lagoon (Island of Mystery)", #("F", 1))),
//   and the list of treasures, and returns the number of treasures that can be found there.

pub fn count_place_treasures(
  place: #(String, #(String, Int)),
  treasures: List(#(String, #(Int, String))),
) -> Int {
  list.fold(treasures, 0, fn(count, l) { todo })
}

// Implement the special_case_swap_possible function, which takes a treasure (such as #("Amethyst Octopus", #(1, "F"))), 
// a Place (such as #("Seaside Cottages", #("C", 1))) and a desired treasure (such as #("Crystal Crab", #(6, "A"))), 
// and returns True for the following combinations:

// The Brass Spyglass can be swapped for any other treasure at the Abandoned Lighthouse.
// The Amethyst Octopus can be swapped for the Crystal Crab or the Glass Starfish at the Stormy Breakwater.
// The Vintage Pirate Hat can be swapped for the Model Ship in Large Bottle or the Antique Glass Fishnet Float at the Harbor Managers Office.

pub fn special_case_swap_possible(
  found_treasure: #(String, #(Int, String)),
  place: #(String, #(String, Int)),
  desired_treasure: #(String, #(Int, String)),
) -> Bool {
  let treasure = found_treasure.0
  let p = place.0
  let d = desired_treasure.0

  case treasure {
    "Brass Spyglass" if p == "Abandoned Lighthouse" -> True
    "Amethyst Octopus"
      if { d == "Crystal Crab" || d == "Glass Starfish" }
      && p == "Stormy Breakwater"
    -> True
    "Vintage Pirate Hat"
      if {
        d == "Model Ship in Large Bottle"
        || d == "Antique Glass Fishnet Float"
      }
      && p == "Harbor Managers Office"
    -> True
    _ -> False
  }
}
