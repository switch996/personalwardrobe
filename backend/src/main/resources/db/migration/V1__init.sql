CREATE TABLE users (
    id VARCHAR(64) PRIMARY KEY,
    phone VARCHAR(32) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE refresh_tokens (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL,
    token TEXT NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    CONSTRAINT fk_refresh_tokens_user FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE outfits (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL,
    wear_date DATE NOT NULL,
    note TEXT,
    image_url TEXT,
    image_media_id VARCHAR(64),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT fk_outfits_user FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE outfit_tags (
    outfit_id VARCHAR(64) NOT NULL,
    tag VARCHAR(64) NOT NULL,
    CONSTRAINT fk_outfit_tags_outfit FOREIGN KEY (outfit_id) REFERENCES outfits (id) ON DELETE CASCADE
);

CREATE TABLE outfit_closet_item_ids (
    outfit_id VARCHAR(64) NOT NULL,
    closet_item_id VARCHAR(64) NOT NULL,
    CONSTRAINT fk_outfit_closet_item_ids_outfit FOREIGN KEY (outfit_id) REFERENCES outfits (id) ON DELETE CASCADE
);

CREATE TABLE closet_items (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL,
    name VARCHAR(128) NOT NULL,
    category VARCHAR(32) NOT NULL,
    brand VARCHAR(128),
    color VARCHAR(64),
    note TEXT,
    image_url TEXT,
    image_media_id VARCHAR(64),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT fk_closet_items_user FOREIGN KEY (user_id) REFERENCES users (id),
    CONSTRAINT ck_closet_category CHECK (category IN ('top', 'bottom', 'shoes', 'accessory', 'outerwear', 'dress', 'bag'))
);

CREATE TABLE media (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL,
    url TEXT NOT NULL,
    content_type VARCHAR(128) NOT NULL,
    size BIGINT NOT NULL,
    width INTEGER,
    height INTEGER,
    thumbnail_url TEXT,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT fk_media_user FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE INDEX idx_outfits_user_updated ON outfits (user_id, updated_at);
CREATE INDEX idx_outfits_user_deleted ON outfits (user_id, deleted_at);
CREATE INDEX idx_closet_items_user_updated ON closet_items (user_id, updated_at);
CREATE INDEX idx_closet_items_user_deleted ON closet_items (user_id, deleted_at);
CREATE INDEX idx_media_user_deleted ON media (user_id, deleted_at);
CREATE INDEX idx_refresh_tokens_user_revoked ON refresh_tokens (user_id, revoked);
