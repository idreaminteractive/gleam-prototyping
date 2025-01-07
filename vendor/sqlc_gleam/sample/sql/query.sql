-- name: ListUsers :many 
SELECT
    *
FROM
    user;

-- name: ListPosts :many 
Select
    *
from
    post;

-- name: GetUserById :one 
SELECT
    *
FROM
    user
WHERE
    id = ?;

-- name: GetAnotherOne :one 
SELECT
    email,
    created_at
FROM
    user
WHERE
    id = 1;

-- name: GetPostsByUser :many
SELECT
    p.id,
    p.title,
    u.id as uid,
    u.email
from
    post p
    join user u on u.id = p.owner_id
where
    u.id = ?;

-- name: GetPostsByListOfUsers :many 
SELECT
    p.id,
    p.title,
    u.id as uid
from
    post p
    left join user u on u.id = p.owner_id
WHERE
    u.id IN (sqlc.slice('ids'));

-- name: CreateUser :one 
insert into
    user (name, email)
values
    (?, ?) returning *;

-- name: CreatePost :one 
insert into
    post (title, owner_id)
values
    (?, ?) returning *;

-- name: UpdatePost :one 
update
    post
set
    title = ?
where
    id = ? returning *;

-- name: ClearPosts :exec 
delete from
    post;