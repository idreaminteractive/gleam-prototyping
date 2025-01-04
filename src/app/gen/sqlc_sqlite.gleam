//// Code generated by sqlc_gen_gleam. DO NOT EDIT.
//// versions:
////   sqlc_gen_gleam v1.0.0
////

import birl
import gleam/dynamic/decode
import gleam/option.{type Option}

import sqlight

fn decode_birl_time_from_string() -> decode.Decoder(birl.Time) {
  decode.string
  |> decode.then(fn(v: String) {
    case birl.parse(v) {
      Ok(time) -> decode.success(time)
      Error(_err) -> decode.success(birl.now())
    }
  })
}

pub type GetAnotherOne {
  GetAnotherOne(email: String, created_at: birl.Time)
}

fn get_another_one_decoder() {
  use email <- decode.field(0, decode.string)
  use created_at <- decode.field(1, decode_birl_time_from_string())
  decode.success(GetAnotherOne(email:, created_at:))
}

fn get_another_one_sql() {
  "Select
    email,
    created_at
from
    user
where
    id = 1"
}

pub fn get_another_one(conn: sqlight.Connection) {
  sqlight.query(
    get_another_one_sql(),
    on: conn,
    with: [],
    expecting: get_another_one_decoder(),
  )
  // if we get MORE Than one and i just want one, will it
  // end 
}

pub type GetUserById {
  GetUserById(id: Int, email: String)
}

fn get_user_by_id_decoder() {
  use id <- decode.field(0, decode.int)
  use email <- decode.field(1, decode.string)
  decode.success(GetUserById(id:, email:))
}

fn get_user_by_id_sql() {
  "SELECT
    id,
    email
FROM
    user
WHERE
    id = ?"
}

pub fn get_user_by_id(conn: sqlight.Connection, id: Int) {
  sqlight.query(
    get_user_by_id_sql(),
    on: conn,
    with: [sqlight.int(id)],
    expecting: get_user_by_id_decoder(),
  )
}
