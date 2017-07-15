DROP TABLE IF EXISTS ofh_user;
-- Or account?
CREATE TABLE ofh_user (
  id uuid PRIMARY KEY,
  username varchar(255),
  email citext UNIQUE,
  phone varchar(50)
-- More to come, (address, country etc)
);

DROP TABLE IF EXISTS ofh_file;
CREATE TABLE ofh_file (
  id uuid PRIMARY KEY,
  md5sum uuid UNIQUE,
  name text, --varchar(255)? --filename?
  mimetype varchar(255),
  data text, --Base64 encoded data
  created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  CHECK(EXTRACT(TIMEZONE FROM created) = '0')
);
-- TODO: Image styles thingy

DROP TABLE IF EXISTS ofh_user_image;
CREATE TABLE ofh_user_image (
  user_id uuid REFERENCES ofh_user(id),
  file_id uuid REFERENCES ofh_file(id),
  width smallint, --TODO: type??
  height smallint,
  caption text,
  alt text
);

-- Location table??
DROP TABLE IF EXISTS ofh_location;
CREATE TABLE ofh_location (
  id uuid PRIMARY KEY
  --geodatablblblba
);

-- Hmm??
--CREATE TABLE ofh_user_buyer (
--  id uuid PRIMARY KEY,
--);
-- vendor?
DROP TABLE IF EXISTS ofh_account_seller;
CREATE TABLE ofh_account_seller (
  id uuid PRIMARY KEY
  --user_image_id
);
