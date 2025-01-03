import gleam/dynamic/decode
import gleam/option.{type Option}
import gleam/result
import sqlight

pub type GetUserById {
  GetUserById(id: Int, email: String)
}

fn get_user_by_id_decoder() {
  use id <- decode.field(0, decode.int)
  use email <- decode.field(1, decode.string)
  decode.success(GetUserById(id:, email:))
}

fn get_user_by_id_sql(id: Int) {
  let sql =
    "
  SELECT
    id,
    email
FROM
    user
WHERE
    id = ?;
  "

  sql
}

pub fn get_user_by_id(conn: sqlight.Connection, id: Int) {
  sqlight.query(
    get_user_by_id_sql(id),
    on: conn,
    with: [sqlight.int(id)],
    expecting: get_user_by_id_decoder(),
  )
}

pub type ListUsersRow {
  ListUsersRow(
    id: Int,
    name: String,
    optional_example: Option(Int),
    email: String,
    created_at: Int,
    updated_at: Int,
  )
}

pub type ListUsers =
  List(ListUsersRow)

pub fn list_users_sql() {
  let sql =
    "
 SELECT
    *
FROM
    user;
  "
  #(sql, Nil)
}
