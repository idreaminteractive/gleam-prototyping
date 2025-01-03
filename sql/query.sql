-- name: ListUsers :many 
SELECT
    *
FROM
    users;

-- name: GetUserById :one 
SELECT
    id
FROM
    users
WHERE
    id = ?;