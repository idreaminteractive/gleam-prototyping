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