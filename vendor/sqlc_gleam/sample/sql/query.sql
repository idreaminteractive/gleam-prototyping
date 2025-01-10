-- name: ListUsers :many 
SELECT
    *
FROM
    user;

-- name: ListPosts :many 
SELECT
    *
FROM
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
    u.id AS uid,
    u.email
FROM
    post p
    INNER JOIN user u ON u.id = p.owner_id
WHERE
    u.id = ?;

-- name: GetPostsByListOfUsers :many 
SELECT
    p.id,
    p.title,
    u.id AS uid
FROM
    post p
    LEFT JOIN user u ON u.id = p.owner_id
WHERE
    u.id IN (sqlc.slice('ids'));

-- name: CreateUser :one 
INSERT INTO
    user (name, email)
VALUES
    (?, ?) returning *;

-- name: CreatePost :one 
INSERT INTO
    post (title, owner_id)
VALUES
    (?, ?) returning *;

-- name: UpdatePost :one 
UPDATE
    post
SET
    title = ?
WHERE
    id = ? returning *;

-- name: ClearPosts :exec 
DELETE FROM
    post;