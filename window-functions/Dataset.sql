-- ============================================================
-- RetailCRM Dataset — SQL Window Functions Interview Prep
-- Paste Schema SQL in LEFT box, then your query in RIGHT box
-- Compatible: PostgreSQL 13+ / MySQL 8+ / DB Fiddle
-- ============================================================

CREATE TABLE customers (
  customer_id  INT PRIMARY KEY,
  full_name    VARCHAR(100),
  email        VARCHAR(100),
  city         VARCHAR(50),
  signup_date  DATE
);

CREATE TABLE sales_reps (
  rep_id    INT PRIMARY KEY,
  rep_name  VARCHAR(100),
  region    VARCHAR(50)
);

CREATE TABLE products (
  product_id    INT PRIMARY KEY,
  product_name  VARCHAR(100),
  category      VARCHAR(50),
  list_price    NUMERIC(10,2)
);

CREATE TABLE orders (
  order_id      INT PRIMARY KEY,
  customer_id   INT,
  rep_id        INT,
  order_date    DATE,
  total_amount  NUMERIC(10,2)
);

CREATE TABLE order_items (
  item_id     INT PRIMARY KEY,
  order_id    INT,
  product_id  INT,
  quantity    INT,
  unit_price  NUMERIC(10,2)
);

-- CUSTOMERS
INSERT INTO customers VALUES
(1,'Priya Sharma','priya@email.com','Mumbai','2022-01-15'),
(2,'Rahul Gupta','rahul@email.com','Delhi','2022-03-20'),
(3,'Anita Singh','anita@email.com','Bangalore','2022-05-10'),
(4,'Vikram Patel','vikram@email.com','Chennai','2022-06-01'),
(5,'Neha Joshi','neha@email.com','Hyderabad','2022-07-22'),
(6,'Amit Kumar','amit@email.com','Pune','2022-08-14'),
(7,'Sunita Rao','sunita@email.com','Kolkata','2022-09-05'),
(8,'Deepak Mehta','deepak@email.com','Ahmedabad','2022-10-18');

-- SALES REPS
INSERT INTO sales_reps VALUES
(1,'Ravi Nair','North'),
(2,'Kavya Reddy','South'),
(3,'Arjun Das','East'),
(4,'Meena Iyer','West');

-- PRODUCTS
INSERT INTO products VALUES
(1,'Laptop Pro','Electronics',75000),
(2,'Wireless Mouse','Electronics',1200),
(3,'Office Chair','Furniture',12000),
(4,'Standing Desk','Furniture',25000),
(5,'Notebook Set','Stationery',450),
(6,'Backpack','Accessories',3500),
(7,'Monitor 27"','Electronics',22000),
(8,'Mechanical Keyboard','Electronics',4500);

-- ORDERS
INSERT INTO orders VALUES
(1,1,1,'2023-01-10',76200),
(2,1,1,'2023-02-15',1200),
(3,1,2,'2023-03-05',12000),
(4,2,1,'2023-01-20',25000),
(5,2,2,'2023-02-28',450),
(6,2,3,'2023-03-15',75000),
(7,3,2,'2023-01-05',4500),
(8,3,2,'2023-01-25',22000),
(9,3,3,'2023-04-10',3500),
(10,4,4,'2023-02-10',12000),
(11,4,4,'2023-03-20',76200),
(12,5,1,'2023-01-30',1200),
(13,5,2,'2023-03-01',25000),
(14,6,3,'2023-02-05',450),
(15,6,4,'2023-04-15',22000),
(16,7,1,'2023-01-12',4500),
(17,7,3,'2023-02-18',3500),
(18,7,4,'2023-03-25',75000),
(19,8,2,'2023-01-08',12000),
(20,8,4,'2023-04-20',76200),
(21,1,1,'2023-05-10',25000),
(22,2,2,'2023-05-18',4500),
(23,3,3,'2023-06-01',1200),
(24,4,1,'2023-06-15',22000),
(25,5,4,'2023-07-05',450);

-- ORDER ITEMS
INSERT INTO order_items VALUES
(1,1,1,1,75000),(2,1,2,1,1200),(3,2,2,1,1200),
(4,3,3,1,12000),(5,4,4,1,25000),(6,5,5,2,450),
(7,6,1,1,75000),(8,7,8,1,4500),(9,8,7,1,22000),
(10,9,6,1,3500),(11,10,3,1,12000),(12,11,1,1,75000),
(13,11,2,1,1200),(14,12,2,1,1200),(15,13,4,1,25000),
(16,14,5,3,450),(17,15,7,1,22000),(18,16,8,1,4500),
(19,17,6,1,3500),(20,18,1,1,75000),(21,19,3,1,12000),
(22,20,1,1,75000),(23,20,2,1,1200),(24,21,4,1,25000),
(25,22,8,1,4500),(26,23,2,2,1200),(27,24,7,1,22000),
(28,25,5,1,450);