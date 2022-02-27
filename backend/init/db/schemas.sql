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
  options TEXT
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
  is_used BOOLEAN DEFAULT false,
  created_by VARCHAR(255) NOT NULL
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
  payment TEXT,
  fail_reason TEXT,
  creator_type VARCHAR(8) NOT NULL,
  creator_staff VARCHAR(255),
  creator_cus VARCHAR(255),
  created_at BIGINT
);

CREATE INDEX idx_order_state ON orders(state);
CREATE INDEX idx_order_creator_cus ON orders(creator_cus);
CREATE INDEX idx_order_created_at ON orders(created_at DESC);

CREATE TABLE order_items (
  order_id INT REFERENCES orders(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  unit_price BIGINT,
  quantity INT,
  note TEXT,
  options TEXT
);

CREATE INDEX idx_order_items ON order_items (order_id);

CREATE TABLE store_configs (
  cfg_key VARCHAR(255) NOT NULL PRIMARY KEY,
  cfg_val VARCHAR(255) NOT NULL
);
