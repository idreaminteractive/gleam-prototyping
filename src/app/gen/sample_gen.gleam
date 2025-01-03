import gleam/option.{type Option}

pub type GetUserById {
  GetUserById(id: Int, email: String)
}

pub fn get_user_by_id(id: Int) {
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

  #(sql, #(id))
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
