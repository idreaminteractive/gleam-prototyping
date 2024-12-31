import gleam/list
import gleam/result

pub type Player {
  Black
  White
}

pub type Game {
  Game(
    white_captured_stones: Int,
    black_captured_stones: Int,
    player: Player,
    error: String,
  )
}

// here are 4 rules in the game:

// Each point can only have one stone.
// Opposition stones can be captured.
// You can not place a stone where it would capture itself.
// You can not use the same point twice.

pub fn apply_rules(
  game: Game,
  rule1: fn(Game) -> Result(Game, String),
  rule2: fn(Game) -> Game,
  rule3: fn(Game) -> Result(Game, String),
  rule4: fn(Game) -> Result(Game, String),
) -> Game {
  // -> If all rules pass, return a `Game` with all changes from the rules applied, and change player
  // -> If any rule fails, return the original Game, but with the error field set
  let result = {
    use g <- result.try(rule1(game))
    let g2 = rule2(g)
    use g3 <- result.try(rule3(g2))
    use g4 <- result.try(rule4(g3))
    Ok(g4)
  }
  case result {
    Ok(g) -> {
      case g.player {
        White -> Game(..g, player: Black)
        Black -> Game(..g, player: White)
      }
    }
    Error(err) -> Game(..game, error: err)
  }
}
