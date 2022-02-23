-- Initial SQL script to initialize the database for QRMOS.

-- For PRODUCTION: need to have database named `qrmos` CREATED
--   to be able to run this script.

-- For DEVELOPMENT: this script will be executed when database 
--   docker-compose container run for the first time

USE qrmos;

CREATE TABLE users (
  username VARCHAR(255) NOT NULL PRIMARY KEY,
  password VARCHAR(255) NOT NULL,
  password_salt VARCHAR(255) NOT NULL,
  full_name VARCHAR(30) NOT NULL,
  role VARCHAR(12),
  active BOOLEAN DEFAULT true
);

CREATE TABLE delivery_destinations (
  name VARCHAR(255) NOT NULL PRIMARY KEY,
  security_code VARCHAR(255) NOT NULL
);

CREATE TABLE menu_categories (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) UNIQUE NOT NULL,
  description TEXT
);

CREATE TABLE menu_items (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) UNIQUE NOT NULL,
  description TEXT,
  image TEXT,
  available BOOLEAN DEFAULT true,
  base_unit_price BIGINT,
  options BLOB
);

CREATE TABLE menu_associations (
  cat_id INT,
  item_id INT,
  PRIMARY KEY(cat_id,item_id),
  FOREIGN KEY (cat_id) REFERENCES menu_categories(id) ON DELETE CASCADE,
  FOREIGN KEY (item_id) REFERENCES menu_items(id) ON DELETE CASCADE
);

CREATE TABLE vouchers (
  code VARCHAR(255) NOT NULL PRIMARY KEY,
  discount BIGINT,
  is_used BOOLEAN DEFAULT false
);

CREATE TABLE orders (
  id INT PRIMARY KEY AUTO_INCREMENT,
  state VARCHAR(255) NOT NULL,
  cus_name VARCHAR(255) NOT NULL,
  cus_phone VARCHAR(255),
  deliver_dest VARCHAR(255) NOT NULL,
  voucher VARCHAR(255),
  discount BIGINT DEFAULT 0,
  total BIGINT DEFAULT 0,
  payment BLOB,
  fail_reason TEXT,
  creator BLOB,
  created_at BIGINT
);

CREATE TABLE order_items (
  order_id INT REFERENCES orders(id),
  name VARCHAR(255) NOT NULL,
  unit_price BIGINT,
  quantity INT,
  options BLOB
);
