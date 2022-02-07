-- Initial SQL script to initialize the database for QRMOS.

-- For PRODUCTION: need to have database named `qrmos` CREATED
--   to be able to run this script.

-- For DEVELOPMENT: this script will be executed when database 
--   docker-compose container run for the first time

USE qrmos;

-- TODO: remove this `users` table, since it's just a placeholder
CREATE TABLE users (
  id INT(6) AUTO_INCREMENT PRIMARY KEY,
  firstname VARCHAR(30) NOT NULL,
  lastname VARCHAR(30) NOT NULL,
  email VARCHAR(50)
);
