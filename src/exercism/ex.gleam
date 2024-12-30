import gleam/list

// TODO: please define the Pizza custom type
pub type Pizza {
  Margherita
  Caprese
  Formaggio
  ExtraSauce(Pizza)
  ExtraToppings(Pizza)
}

// Margherita: $7
// Caprese: $9
// Formaggio: $10
// Customers can also choose two additional options for a small additional fee:

// Extra sauce: $1
// Extra toppings: $2
// When customers place an order, an additional fee is added if they only order one or two pizzas:

// 1 pizza: $3
// 2 pizzas: $2

pub fn pizza_price(pizza: Pizza) -> Int {
  pizza_price_fn(pizza)
}

fn pizza_price_fn(pizza: Pizza) -> Int {
  case pizza {
    Margherita -> 7
    Caprese -> 9
    Formaggio -> 10
    ExtraSauce(a) -> 1 + pizza_price_fn(a)
    ExtraToppings(a) -> 2 + pizza_price_fn(a)
  }
}

pub fn order_price(order: List(Pizza)) -> Int {
  case order {
    [_] -> 3 + list.fold(order, 0, fn(price, pz) { pizza_price(pz) + price })
    [_, _] -> 2 + list.fold(order, 0, fn(price, pz) { pizza_price(pz) + price })
    _ -> list.fold(order, 0, fn(price, pz) { pizza_price(pz) + price })
  }
}
