-- CREATE EXTENSION postgis;
-- CREATE EXTENSION citext;

DROP TABLE IF EXISTS ofh_user;
-- Or account?
CREATE TABLE ofh_user (
  `id` UUID PRIMARY KEY,
  `login` VARCHAR(255), --login/name/username?
  `email` CITEXT UNIQUE,
  `phone` VARCHAR(50)
  -- etc
);

DROP TABLE IF EXISTS ofh_user_group;
CREATE TABLE ofh_user_group (
  `id` UUID PRIMARY KEY,
  `name` VARCHAR(255)
);

DROP TABLE IF EXISTS ofh_file;
CREATE TABLE ofh_file (
  `id` UUID PRIMARY KEY,
  `md5sum` UUID UNIQUE,
  `name` TEXT, --varchar(255)? --filename?
  `mimetype` VARCHAR(255),
  `data` TEXT, --Base64 encoded data
  `created` TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(), --TODO: how handle in sane way?
  CHECK(EXTRACT(TIMEZONE FROM created) = '0')
);
-- TODO: Image styles thingy

DROP TABLE IF EXISTS ofh_user_image;
CREATE TABLE ofh_user_image (
  `id` UUID PRIMARY KEY,
  `file_id` UUID REFERENCES ofh_file(id),
  `width` SMALLINT, --TODO: type??
  `height` SMALLINT,
  `caption` TEXT,
  `alt` TEXT,
  `owner_id` UUID REFERENCES ofh_user(id),
  `creator_id` UUID REFERENCES ofh_user(id) --?? author_id? messy?
);

-- ofh_location?
DROP TABLE IF EXISTS ofh_place;
CREATE TABLE ofh_place (
  `id` UUID PRIMARY KEY,
  `lonlat` GEOGRAPHY(POINT, 4326), --WGS8
  `marker_type` VARCHAR(255), -- No marker table, types statically defined within app?
  `marker_title` VARCHAR(255),
  `info_window_title` VARCHAR(255),
  `info_window_description` VARCHAR(255),
  `info_window_href` VARCHAR(255) --TODO: change type
);

DROP TABLE IF EXISTS ofh_address;
CREATE TABLE ofh_address (
  `id` UUID PRIMARY KEY,
  `line_1` VARCHAR(255),
  `line_2` VARCHAR(255),
  `line_3` VARCHAR(255),
  `line_4` VARCHAR(255),
  `locality` VARCHAR(255),
  `region` VARCHAR(255),
  `postcode` VARCHAR(16),
  `country` VARCHAR(2), --ISO 3166-1 alpha-2 country code
  `place_id` UUID REFERENCES ofh_place(id)
);

/*
DROP TABLE IF EXISTS ofh_external_link;
CREATE TABLE ofh_external_link (
  `id` UUID PRIMARY KEY,
  `url` VARCHAR(255),
  --`aria_label` VARCHAR(255),
  --`fa_icon` VARCHAR(255),
);
*/
-- Hmm??
-- Merge with user?
CREATE TABLE ofh_account_buyer (
  `id` UUID PRIMARY KEY,
  `first_name` VARCHAR(255),
  `last_name` VARCHAR(255),
  `owner_id` UUID REFERENCES ofh_user(id),
  `group_id` UUID REFERENCES ofh_user_group(id),
);

-- GROUP?
DROP TABLE IF EXISTS ofh_account_seller;
CREATE TABLE ofh_account_seller (
  `id` UUID PRIMARY KEY
  `name` VARCHAR(255),
  --short_description VARCHAR(255), --?? --mission?
  `description` TEXT, --presentation?
  `cover_image` UUID REFERENCES ofh_user_image(id),
  `logo_image` UUID REFERENCES ofh_user_image(id),
  `webpage_url` VARCHAR(255), -- TODO: Generic link field?
  -- TODO: facebook, twitter, instagram etc, social links??
  `visiting_address_id` UUID REFERENCES ofh_address(id),
  `group_id` UUID REFERENCES ofh_user_group(id),
);

-- TODO: More generic solution for tagging/taxonomy
DROP TABLE IF EXISTS ofh_account_seller_category (
CREATE TABLE ofh_account_seller_category (
  account_seller_id UUID REFERENCES ofh_account_seller(id),
  seller_category VARCHAR(255) -- statically handeled within app, Farm/Creamery/Brewery/Smokery etc? Or free tagging?
); --TODO Add compound primary key constraint!

DROP TABLE IF EXISTS ofh_product;
CREATE TABLE ofh_product (
);
DROP TABLE IF EXISTS ofh_product_revision;
CREATE TABLE ofh_product_revision (
);
-- ACL
-- Models under access control:
-- product
-- user_image
--

-- PSEUDOCODE load_products('edit', grants
DROP TABLE IF EXISTS ofh_grants (
CREATE TABLE ofh_grants (
  id UUID PRIMARY KEY, --Or compound key?
  user_id UUID,
  realm VARCHAR(255), --??
  operation VARCHAR(255)
  --grant_view smallint, ??
  --grant_update smallint, --grant_update
  --grant_delete smallint,
  --grant_id UUID
);

-- TODO: Reviews, but later!
-- TODO: add timestamp fields for tables? Revisioning? Of what?
