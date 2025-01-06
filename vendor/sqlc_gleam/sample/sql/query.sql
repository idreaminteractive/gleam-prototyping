-- name: ListUsers :many 
SELECT
    *
FROM
    user;

-- name: GetUserById :one 
SELECT
    id,
    email
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