-- migrate:up
CREATE TABLE users (
    id integer,
    name varchar(255),
    email varchar(255) NOT NULL
);

-- migrate:down