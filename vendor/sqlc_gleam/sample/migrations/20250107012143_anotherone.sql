-- migrate:up
PRAGMA defer_foreign_keys = ON;

PRAGMA foreign_keys = OFF;

CREATE TABLE post (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title varchar(255) NOT NULL,
    is_public Boolean default FALSE,
    owner_id Integer not null,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES user (id) ON DELETE CASCADE
);

CREATE TRIGGER post_update_updated_at_trigger
AFTER
UPDATE
    ON post FOR EACH ROW BEGIN
UPDATE
    post
SET
    updated_at = CURRENT_TIMESTAMP
WHERE
    rowid = NEW.rowid;

END;

PRAGMA foreign_key_check;

PRAGMA foreign_keys = ON;

PRAGMA defer_foreign_keys = OFF;

-- migrate:down