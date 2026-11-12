DROP DATABASE IF EXISTS smartmart_retail_sql_project;
CREATE DATABASE smartmart_retail_sql_project;
USE smartmart_retail_sql_project;

SET SESSION cte_max_recursion_depth = 50000;

# =============================================================
# 1. CUSTOMERS TABLE
# =============================================================
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    gender VARCHAR(20) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    registration_date DATE NOT NULL,
    customer_segment VARCHAR(30) DEFAULT 'Regular',
    email VARCHAR(120) UNIQUE,
    phone_number VARCHAR(15) UNIQUE,
    CHECK (gender IN ('Male','Female','Other')),
    CHECK (customer_segment IN ('Regular','Silver','Gold','Platinum'))
);

# =============================================================
# 2. EMPLOYEES TABLE
# =============================================================
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    gender VARCHAR(20) NOT NULL,
    city VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL DEFAULT 'Sales',
    joining_date DATE NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    CHECK (gender IN ('Male','Female','Other')),
    CHECK (salary >= 10000)
);

# =============================================================
# 3. PRODUCTS TABLE
# =============================================================
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(60) NOT NULL,
    brand VARCHAR(80) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    cost_price DECIMAL(10,2) NOT NULL,
    launch_date DATE NOT NULL,
    product_status VARCHAR(20) DEFAULT 'Active',
    CHECK (unit_price > 0),
    CHECK (cost_price > 0),
    CHECK (product_status IN ('Active','Inactive'))
);

# =============================================================
# 4. ORDERS TABLE
# =============================================================
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    employee_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_status VARCHAR(30) NOT NULL DEFAULT 'Completed',
    payment_mode VARCHAR(30) NOT NULL, 
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CHECK (order_status IN ('Completed','Cancelled','Returned')),
    CHECK (payment_mode IN ('Cash','UPI','Credit Card','Debit Card','Net Banking'))
);

# =============================================================
# 5. ORDER_ITEMS TABLE
# =============================================================
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    line_total DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    CHECK (quantity > 0),
    CHECK (unit_price > 0),
    CHECK (discount_percent BETWEEN 0 AND 50)
);

# =============================================================
# INSERT 20,000 CUSTOMERS
# =============================================================
INSERT INTO customers
(customer_id, customer_name, gender, city, state, registration_date, customer_segment, email, phone_number)
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 20000
)
SELECT
    100000 + n AS customer_id,
    CONCAT('Customer_', n) AS customer_name,
    CASE MOD(n,3)
        WHEN 0 THEN 'Male'
        WHEN 1 THEN 'Female'
        ELSE 'Other'
    END AS gender,
    CASE MOD(n,8)
        WHEN 0 THEN 'Hyderabad'
        WHEN 1 THEN 'Bengaluru'
        WHEN 2 THEN 'Chennai'
        WHEN 3 THEN 'Mumbai'
        WHEN 4 THEN 'Pune'
        WHEN 5 THEN 'Delhi'
        WHEN 6 THEN 'Kolkata'
        ELSE 'Ahmedabad'
    END AS city,
    CASE MOD(n,8)
        WHEN 0 THEN 'Telangana'
        WHEN 1 THEN 'Karnataka'
        WHEN 2 THEN 'Tamil Nadu'
        WHEN 3 THEN 'Maharashtra'
        WHEN 4 THEN 'Maharashtra'
        WHEN 5 THEN 'Delhi'
        WHEN 6 THEN 'West Bengal'
        ELSE 'Gujarat'
    END AS state,
    DATE_ADD('2021-01-01', INTERVAL MOD(n, 1460) DAY) AS registration_date,
    CASE
        WHEN MOD(n,20) = 0 THEN 'Platinum'
        WHEN MOD(n,10) = 0 THEN 'Gold'
        WHEN MOD(n,5) = 0 THEN 'Silver'
        ELSE 'Regular'
    END AS customer_segment,
    CONCAT('customer', n, '@smartmartmail.com') AS email,
    CONCAT('9', LPAD(n, 9, '0')) AS phone_number
FROM numbers;

# =============================================================
# INSERT 2,000 EMPLOYEES
# =============================================================
INSERT INTO employees
(employee_id, employee_name, gender, city, department, joining_date, salary)
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 2000
)
SELECT
    50000 + n AS employee_id,
    CONCAT('Employee_', n) AS employee_name,
    CASE MOD(n,3)
        WHEN 0 THEN 'Male'
        WHEN 1 THEN 'Female'
        ELSE 'Other'
    END AS gender,
    CASE MOD(n,6)
        WHEN 0 THEN 'Hyderabad'
        WHEN 1 THEN 'Bengaluru'
        WHEN 2 THEN 'Chennai'
        WHEN 3 THEN 'Mumbai'
        WHEN 4 THEN 'Pune'
        ELSE 'Delhi'
    END AS city,
    CASE MOD(n,4)
        WHEN 0 THEN 'Sales'
        WHEN 1 THEN 'Customer Support'
        WHEN 2 THEN 'Store Operations'
        ELSE 'Billing'
    END AS department,
    DATE_ADD('2020-01-01', INTERVAL MOD(n, 1800) DAY) AS joining_date,
    18000 + (MOD(n, 60) * 1000) AS salary
FROM numbers;  

# =============================================================
# INSERT 5,000 PRODUCTS
# =============================================================
INSERT INTO products
(product_id, product_name, category, brand, unit_price, cost_price, launch_date, product_status)
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 5000
)
SELECT
    200000 + n AS product_id,
    CONCAT('Product_', n) AS product_name,
    CASE MOD(n,8)
        WHEN 0 THEN 'Electronics'
        WHEN 1 THEN 'Fashion'
        WHEN 2 THEN 'Grocery'
        WHEN 3 THEN 'Home Appliances'
        WHEN 4 THEN 'Beauty'
        WHEN 5 THEN 'Sports'
        WHEN 6 THEN 'Furniture'
        ELSE 'Stationery'
    END AS category,
    CASE MOD(n,10)
        WHEN 0 THEN 'Samsung'
        WHEN 1 THEN 'Apple'
        WHEN 2 THEN 'Nike'
        WHEN 3 THEN 'Puma'
        WHEN 4 THEN 'LG'
        WHEN 5 THEN 'Sony'
        WHEN 6 THEN 'Boat'
        WHEN 7 THEN 'Prestige'
        WHEN 8 THEN 'Himalaya'
        ELSE 'SmartMart'
    END AS brand,
    CASE MOD(n,8)
        WHEN 0 THEN 15000 + MOD(n, 40000)
        WHEN 1 THEN 500 + MOD(n, 5000)
        WHEN 2 THEN 50 + MOD(n, 2000)
        WHEN 3 THEN 3000 + MOD(n, 25000)
        WHEN 4 THEN 100 + MOD(n, 3000)
        WHEN 5 THEN 300 + MOD(n, 7000)
        WHEN 6 THEN 5000 + MOD(n, 50000)
        ELSE 20 + MOD(n, 1000)
    END AS unit_price,
    ROUND((
        CASE MOD(n,8)
            WHEN 0 THEN 15000 + MOD(n, 40000)
            WHEN 1 THEN 500 + MOD(n, 5000)
            WHEN 2 THEN 50 + MOD(n, 2000)
            WHEN 3 THEN 3000 + MOD(n, 25000)
            WHEN 4 THEN 100 + MOD(n, 3000)
            WHEN 5 THEN 300 + MOD(n, 7000)
            WHEN 6 THEN 5000 + MOD(n, 50000)
            ELSE 20 + MOD(n, 1000)
        END
    ) * 0.70, 2) AS cost_price,
    DATE_ADD('2021-01-01', INTERVAL MOD(n, 1600) DAY) AS launch_date,
    CASE WHEN MOD(n,25) = 0 THEN 'Inactive' ELSE 'Active' END AS product_status
FROM numbers;

# =============================================================
# INSERT 20,000 ORDERS
# =============================================================
INSERT INTO orders
(order_id, customer_id, employee_id, order_date, order_status, payment_mode)
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 20000
)
SELECT
    300000 + n AS order_id,
    100000 + MOD(n, 20000) + 1 AS customer_id,
    50000 + MOD(n, 2000) + 1 AS employee_id,
    DATE_ADD('2023-01-01', INTERVAL MOD(n, 900) DAY) AS order_date,
    CASE
        WHEN MOD(n,20) = 0 THEN 'Returned'
        WHEN MOD(n,15) = 0 THEN 'Cancelled'
        ELSE 'Completed'
    END AS order_status,
    CASE MOD(n,5)
        WHEN 0 THEN 'Cash'
        WHEN 1 THEN 'UPI'
        WHEN 2 THEN 'Credit Card'
        WHEN 3 THEN 'Debit Card'
        ELSE 'Net Banking'
    END AS payment_mode
FROM numbers;

# =============================================================
# INSERT 40,000 ORDER ITEMS
# =============================================================
INSERT INTO order_items
(order_item_id, order_id, product_id, quantity, unit_price, discount_percent, line_total)
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 40000
)
SELECT
    400000 + n AS order_item_id,
    300000 + MOD(n, 20000) + 1 AS order_id,
    p.product_id,
    1 + MOD(n, 5) AS quantity,
    p.unit_price AS unit_price,
    CASE
        WHEN MOD(n,10) = 0 THEN 20
        WHEN MOD(n,5) = 0 THEN 10
        ELSE 0
    END AS discount_percent,
    ROUND((1 + MOD(n, 5)) * p.unit_price *
        (1 - (
            CASE
                WHEN MOD(n,10) = 0 THEN 20
                WHEN MOD(n,5) = 0 THEN 10
                ELSE 0
            END / 100)), 2) AS line_total
FROM numbers
JOIN products p
    ON p.product_id = 200000 + MOD(n, 5000) + 1;
    
# =============================================================
# CREATE INDEXES FOR ANALYSIS PERFORMANCE
# =============================================================
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_employee_id ON orders(employee_id);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_products_category ON products(category);

# =============================================================
# QUICK VALIDATION QUERIES
# =============================================================
SELECT 'customers' AS table_name, COUNT(*) AS total_records FROM customers
UNION ALL
SELECT 'employees', COUNT(*) FROM employees
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;

# let me cross check the data 
select * from customers;
select * from employees;
select * from order_items;
select * from orders;
select * from products;


















