-- CREATE EXTENSION postgis;
-- CREATE EXTENSION citext;

-- CREATE DOMAIN for created timestamp?
-- TODO: NOT NULL, DEFAULT VALUE and other constraints?
CREATE DOMAIN utc_timestamp AS TIMESTAMP WITH TIME ZONE DEFAULT NOW NOT NULL CHECK(EXTRACT(TIMEZONE FROM VALUE) = '0');

/** USER **/
DROP TABLE IF EXISTS ofh_user;
CREATE TABLE ofh_user (
  `id` UUID PRIMARY KEY,
  `login` VARCHAR(255), --login/name/username?
  `email` CITEXT UNIQUE,
  `created` utc_timestamp
  -- etc
);

DROP TABLE IF EXISTS ofh_user_account;
CREATE TABLE ofh_user_account (
  `user_id` REFERENCES ofh_user(id),
  `account_id` REFERENCES ofh_account(id),
  `superuser` boolean,
  PRIMARY KEY(`user_id`, `account_id`)
);

/* ofh_tenant/ofh_account/ofh_role/ofh_user_role/ofh_user_type? ?? */
CREATE TABLE ofh_account (
  `id` UUID PRIMARY KEY,
  `name` varchar(255), -- This is the name visible in comments, etc, better name?
  `type` varchar(255), -- static lookup in app
  `created` utc_timestamp
  -- Unique constraint on (user_id, type) ?
);

/** FILE **/
DROP TABLE IF EXISTS ofh_file;
CREATE TABLE ofh_file (
  `id` UUID PRIMARY KEY,
  `md5sum` UUID UNIQUE,
  `name` TEXT, --varchar(255)? --filename?
  `mimetype` VARCHAR(255),
  `data` TEXT, --Base64 encoded data
  `created` utc_timestamp,
  CHECK(EXTRACT(TIMEZONE FROM created) = '0')
);
-- TODO: Image styles thingy
-- TODO: External video, youtube, vimeo etc, no video hosting!
/** USER IMAGE (-> FILE) **/
DROP TABLE IF EXISTS ofh_user_image;
CREATE TABLE ofh_user_image (
  `id` UUID PRIMARY KEY,
  `file_id` UUID REFERENCES ofh_file(id),
  `width` SMALLINT, --TODO: type??
  `height` SMALLINT,
  `caption` TEXT,
  `alt` TEXT,
  `account_id` UUID REFERENCES ofh_account(id),
  `creator_id` UUID REFERENCES ofh_user(id), --?? author_id? messy?
  `created` utc_timestamp
);

/** PLACE **/
-- ofh_location?
DROP TABLE IF EXISTS ofh_place;
CREATE TABLE ofh_place (
  `id` UUID PRIMARY KEY,
  `lonlat` GEOGRAPHY(POINT, 4326), --WGS8
  `marker_type` VARCHAR(255), -- No marker table, types statically defined within app?
  `marker_title` VARCHAR(255),
  `info_window_title` VARCHAR(255),
  `info_window_description` VARCHAR(255),
  `info_window_href` VARCHAR(255), --TODO: change type
  `created` utc_timestamp
);

/** ADDRESS (-> PLACE) **/
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
  `place_id` UUID REFERENCES ofh_place(id),
  `created` utc_timestamp
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
/* Bra skit: https://stackoverflow.com/questions/10068033/postgresql-foreign-key-referencing-primary-keys-of-two-different-tables */
/* OR:
account_type varchar(16) DEFAULT 'buyer' CHECK (account_type = 'buyer'),
*/

/** BUYER ACCOUNT **/
-- Merge with user?
CREATE TABLE ofh_account_buyer (
  `first_name` VARCHAR(255),
  `last_name` VARCHAR(255),
  `phone` VARCHAR(50)
) INHERITS (ofh_account);

/** ofh_account_courier **/

/** SELLER ACCOUNT **/
-- GROUP?
DROP TABLE IF EXISTS ofh_account_seller;
CREATE TABLE ofh_account_seller (
  --short_description VARCHAR(255), --?? --mission?
  `description` TEXT, --presentation?
  `cover_image` UUID REFERENCES ofh_user_image(id),
  `logo_image` UUID REFERENCES ofh_user_image(id),
  `webpage_url` VARCHAR(255), -- TODO: Generic link field?
  -- TODO: facebook, twitter, instagram etc, social links??
  `visiting_address_id` UUID REFERENCES ofh_address(id)
) INHERITS (ofh_account);

/** SELLER CATEGORY (-> SELLER, -> SELLER CATEGORY) **/
-- TODO: More generic solution for tagging/taxonomy
DROP TABLE IF EXISTS ofh_account_seller_seller_category; --Hmm???
CREATE TABLE ofh_account_seller_seller_category (
  `account_seller_id` UUID REFERENCES ofh_account_seller(id),
  `seller_category_id` UUID REFERENCES ofh_seller_category(id),  --Farm/Creamery/Brewery/Smokery etc? Or free tagging?
  PRIMARY KEY(`account_seller_id`, `seller_category_id`)
);

DROP TABLE IF EXISTS ofh_seller_category;
CREATE TABLE ofh_seller_category (
  `id` UUID PRIMARY KEY,
  `name` varchar(255),
  `created` utc_timestamp
  --`description` varchar(255),
  --`icon_image`
);

/** PRODUCT **/
-- Denormalize certain fields (product teaser) for performance? Nah
DROP TABLE IF EXISTS ofh_product;
CREATE TABLE ofh_product (
  `id` UUID PRIMARY KEY,
  `current_product_revision_id` UUID REFERENCES ofh_product_revision(id),
  `user_id` UUID REFERENCES ofh_user(id), --creator_id?
  `account_id` UUID REFERENCES ofh_account_seller(id) --tenant_id/account_id?
);

DROP TABLE IF EXISTS ofh_product_revision;
CREATE TABLE ofh_product_revision (
  `id` UUID PRIMARY KEY,
  `product_id` UUID REFERENCES ofh_product(id),
  `name` varchar(255),
  `price_amount` NUMERIC(19, 4),
  `price_currency` varchar(3), -- ISO 4217 Code
  `description` text,
  `created` utc_timestamp,
  `account_id` UUID REFERENCES ofh_user(id)
);

DROP TABLE IF EXISTS ofh_product_revision_user_image;
CREATE TABLE ofh_product_revision_user_image (
  `product_revision_id` UUID REFERENCES ofh_product_revision(id),
  `user_image_id` UUID REFERENCES ofh_user_image(id)
);

DROP TABLE IF EXISTS ofh_product_revision_product_category;
CREATE TABLE ofh_product_revision_product_category (
  `product_revision_id` UUID REFERENCES ofh_product_revision(id),
  `product_category_id` UUID REFERENCES ofh_product_category(id)
);

DROP TABLE IF EXISTS ofh_product_category;
CREATE TABLE ofh_product_category (
  `id` UUID PRIMARY KEY,
  `name` varchar(255),
  `created` utc_timestamp
);

-- ACL
-- Models under access control:
-- product
-- user_image
--
/*
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
*/

-- TODO: Reviews, but later!
-- TODO: add timestamp fields for tables? Revisioning? Of what?
