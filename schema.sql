DROP TABLE IF EXISTS ofh_account;
-- Or account?
CREATE TABLE ofh_account (
  id uuid PRIMARY KEY,
  username varchar(255),
  email citext UNIQUE,
  phone varchar(50),
  data json
-- More to come, (address, country etc)
);

DROP TABLE IF EXISTS ofh_file;
CREATE TABLE ofh_file (
  id uuid PRIMARY KEY,
  mimetype varchar(255),
  filepath text --source??
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
);
