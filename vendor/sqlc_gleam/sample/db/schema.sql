CREATE TABLE IF NOT EXISTS "schema_migrations" (version varchar(128) primary key);
CREATE TABLE user (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name varchar(255) NOT NULL,
    optional_example INTEGER,
    email varchar(255) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TRIGGER user_update_updated_at_trigger
AFTER
UPDATE
    ON user FOR EACH ROW BEGIN
UPDATE
    user
SET
    updated_at = CURRENT_TIMESTAMP
WHERE
    rowid = NEW.rowid;

END;
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
-- Dbmate schema migrations
INSERT INTO "schema_migrations" (version) VALUES
  ('20250103140218'),
  ('20250107012143');
