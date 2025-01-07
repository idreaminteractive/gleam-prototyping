import gen/sqlc_sqlite
import gleam/io
import gleam/list
import pprint
import sqlight

pub fn main() {
  use conn <- sqlight.with_connection("data/sqlite.db")

  sqlc_sqlite.get_another_one(conn)
  let assert Ok(user) =
    sqlc_sqlite.create_user(conn, name: "dave", email: "dwiper@mail.com")

  let assert Ok(post) =
    sqlc_sqlite.create_post(conn, title: "first post", owner_id: user.id)

  let assert Ok(post) =
    sqlc_sqlite.create_post(conn, title: "second post", owner_id: user.id)

  let assert Ok(post_list) = sqlc_sqlite.list_posts(conn)
  let assert Ok(results) = sqlc_sqlite.get_posts_by_user(conn, user.id)
  sqlc_sqlite.update_post(conn, "new title for second post", post.id)

  let assert Ok(results) = sqlc_sqlite.get_posts_by_user(conn, user.id)
  list.length(results) |> pprint.debug

  let assert Ok(_) = sqlc_sqlite.clear_posts(conn)

  let assert Ok(results) = sqlc_sqlite.get_posts_by_user(conn, user.id)
  list.length(results) |> pprint.debug

  Nil
}
