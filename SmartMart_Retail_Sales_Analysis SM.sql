####################### Retails Sales ####################
use smartmart_retail_sql_project;

######################### 1. Customer Analysis ############
# 1. Management wants to know the total number of customers available for sales and marketing campaigns.
select count(*) from customers;

# 2. City-Wise Customer Distribution
# Q. Management wants to understand which cities have the strongest customer presence.
select * from customers;
# Sol:
select city, count(customer_id) from customers
group by city;

# Analysis 3: Top 10 Customers by Revenue
# Q: The company wants to identify customers who contribute the highest revenue.
select c.customer_id, 
	sum(oi.quantity * oi.unit_price) as total_revenue
from customers c 
inner join orders o
on o.customer_id = c.customer_id
inner join order_items oi
on oi.order_id = o.order_id
group by c.customer_id
order by sum(oi.quantity * oi.unit_price) desc
limit 10;

# Analysis 4: Repeat Customer Analysis
# Q: Management wants to know how many customers are purchasing more than once.
select  c.customer_id,
		count(o.order_id) as total_orders
from customers c 
inner join orders o 
on o.customer_id = c.customer_id
group by c.customer_id
having count(o.order_id) > 1;

# Analysis 5: Customers Who Have Not Purchased
select * 
from customers c
left join orders o 
on o.customer_id = c.customer_id
where o.order_id is null;


# Analysis 6: Customer Segmentation Based on Spending
# Q: Management wants to segment customers based on total spending.
WITH customer_revenue AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * oi.unit_price) AS total_spent
    FROM customers c
    JOIN orders o 
        ON c.customer_id = o.customer_id
    JOIN order_items oi 
        ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT 
    customer_id,
    customer_name,
    ROUND(total_spent, 2) AS total_spent,
    CASE
        WHEN total_spent >= 100000 THEN 'VIP Customer'
        WHEN total_spent >= 50000 THEN 'High Value Customer'
        WHEN total_spent >= 20000 THEN 'Regular Customer'
        ELSE 'Low Value Customer'
    END AS customer_segment
FROM customer_revenue
ORDER BY total_spent DESC;

######################## 2. Product Analysis #########################
# Analysis 7: Top Products by Revenue
# Management wants to identify products that generate the highest revenue.
select p.product_id, 
		p.product_name,
        p.category,
        sum(oi.quantity * oi.unit_price) as total_revenue
from products p
inner join order_items oi
on oi.product_id = p.product_id
group by p.product_id, p.product_name, p.category
order by sum(oi.quantity * oi.unit_price) desc
limit 10;
# Analysis 8: Top Products by Quantity Sold
# Q: The company wants to know which products are most frequently purchased.
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS total_quantity_sold
FROM products p
JOIN order_items oi 
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_quantity_sold DESC
LIMIT 10;

#Analysis 9: Products Never Sold
# Management wants to identify products that are listed but never sold.
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p. unit_price
FROM products p
LEFT JOIN order_items oi 
    ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;

# Analysis 10: Category-Wise Revenue
# Management wants to know which product categories perform best.
select category, sum(oi.quantity * oi.unit_price) as total_revenue
from products p 
inner join order_items oi
on oi.product_id = p.product_id
group by category;

# Analysis 11: Low Performing Products 
# Management wants to identify products generating very low revenue.
select p.product_id,
		p.product_name,
        p.category,
        sum(oi.quantity * oi.unit_price) as total_revenue
from products p
inner join order_items oi
on oi.product_id = p.product_id
group by p.product_id, p.product_name, p.category
having sum(oi.quantity * oi.unit_price) < 5000;

# Analysis 12: Product Ranking by Revenue
# Management wants to rank products within each category.
# Sol: using CTE:
with product_sales as
(SELECT 
        p.product_id,
        p.product_name,
        p.category,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
    FROM products p
    JOIN order_items oi 
        ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name, p.category
)SELECT 
    product_id,
    product_name,
    category,
    total_revenue,
    DENSE_RANK() OVER (
        PARTITION BY category 
        ORDER BY total_revenue DESC
    ) AS product_rank
FROM product_sales;

################################3. Sales Analysis ##############################
# Analysis 13: Total Revenue
select sum(quantity * unit_price) as total_revenue
from order_items;

# Analysis 14: Monthly Revenue Trend
# Management wants to understand monthly revenue movement.
select month(o.order_date) as month,
		sum(oi.quantity * oi.unit_price) as total_revenue
from orders o
inner join order_items oi
on oi.order_id = o.order_id
group by month(o.order_date);

# Analysis 15: Quarterly Revenue Trend
# Management wants to compare revenue across quarters.
select quarter(o.order_date) as quarter,
		sum(oi.quantity * oi.unit_price) as total_revenue
from orders o
inner join order_items oi
on oi.order_id = o.order_id
group by quarter(o.order_date);
# Analysis 16: Average Order Value
# Management wants to know the average revenue generated per order.
with order_revenue as
(select order_id,
		sum(quantity * unit_price) as order_value
from order_items group by order_id)
select avg(order_value) from order_revenue;
# Analysis 17: High Value Orders
WITH order_revenue AS (
    SELECT 
        order_id,
        SUM(quantity * unit_price) AS order_value
    FROM order_items
    GROUP BY order_id
)
SELECT 
    order_id,
    ROUND(order_value, 2) AS order_value
FROM order_revenue
WHERE order_value > (
    SELECT AVG(order_value)
    FROM order_revenue
)
ORDER BY order_value DESC;

############################ 4. Employee Analysis  #########################
# Analysis 18: Employee Revenue Contribution
# Management wants to evaluate sales employee contribution
select e.employee_id, e.employee_name,
sum(oi.quantity * oi.unit_price) as total_revenue
from employees e
inner join orders o
on e.employee_id = o.employee_id
inner join order_items oi
on oi.order_id = o.order_id
group by e.employee_id, e.employee_name 
order by sum(oi.quantity * oi.unit_price) desc;

USE smartmart_retail_sql_project;

SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM employees;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;

############################ Analysis 19: Top 10 Employees #########################
### Management wants to identify best performers.
SELECT
    employee_id,
    employee_name,
    revenue_generated,
    DENSE_RANK() OVER (
        ORDER BY revenue_generated DESC
    ) AS employee_rank
FROM (
    SELECT
        e.employee_id,
        e.employee_name,
        SUM(oi.quantity * oi.unit_price) AS revenue_generated
    FROM employees e
    JOIN orders o
        ON e.employee_id = o.employee_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY e.employee_id, e.employee_name
) AS emp_sales
ORDER BY employee_rank
LIMIT 10;

############################ Analysis 20 – Employees With No Sales #########################
### Management wants to identify employees not linked to any orders.
SELECT
    e.employee_id,
    e.employee_name
FROM employees e
LEFT JOIN orders o
    ON e.employee_id = o.employee_id
WHERE o.order_id IS NULL;

SELECT
    COUNT(*) AS total_employees,
    COUNT(DISTINCT employee_id) AS employees_with_orders
FROM orders;

####8. Advanced Business Analysis######
### Analysis 21: Pareto Analysis - Customer Revenue Concentration ###
### Management wants to know whether a small percentage of customers generate most revenue.
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.customer_name
),

ranked_customers AS (
    SELECT
        customer_id,
        customer_name,
        revenue,
        NTILE(5) OVER (
            ORDER BY revenue DESC
        ) AS customer_group
    FROM customer_revenue
)

SELECT
    customer_group,
    COUNT(*) AS total_customers,
    ROUND(SUM(revenue), 2) AS group_revenue
FROM ranked_customers
GROUP BY customer_group
ORDER BY customer_group;

########### Analysis 22: Running Monthly Revenue ############
#### Management wants to understand cumulative revenue growth.
WITH monthly_sales AS (
    SELECT
        YEAR(o.order_date) AS sales_year,
        MONTH(o.order_date) AS sales_month,
        SUM(oi.quantity * oi.unit_price) AS monthly_revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        YEAR(o.order_date),
        MONTH(o.order_date)
)

SELECT
    sales_year,
    sales_month,
    ROUND(monthly_revenue, 2) AS monthly_revenue,
    ROUND(
        SUM(monthly_revenue) OVER (
            ORDER BY sales_year, sales_month
        ), 2
    ) AS running_revenue
FROM monthly_sales;

### Analysis 23 – Month-over-Month Revenue Change ### 
## Management wants to know whether revenue is increasing or decreasing month by month. 
WITH monthly_sales AS (
    SELECT
        YEAR(o.order_date) AS sales_year,
        MONTH(o.order_date) AS sales_month,
        SUM(oi.quantity * oi.unit_price) AS monthly_revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        YEAR(o.order_date),
        MONTH(o.order_date)
)

SELECT
    sales_year,
    sales_month,
    ROUND(monthly_revenue, 2) AS monthly_revenue,

    ROUND(
        LAG(monthly_revenue) OVER (
            ORDER BY sales_year, sales_month
        ), 2
    ) AS previous_month_revenue,

    ROUND(
        monthly_revenue - LAG(monthly_revenue) OVER (
            ORDER BY sales_year, sales_month
        ), 2
    ) AS revenue_difference

FROM monthly_sales;

### Analysis 24 – Products Above Average Revenue ####
## Management wants to identify products performing better than average.
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name
)

SELECT
    product_id,
    product_name,
    ROUND(revenue, 2) AS revenue
FROM product_revenue
WHERE revenue > (
    SELECT AVG(revenue)
    FROM product_revenue
)
ORDER BY revenue DESC;

### Analysis 25: Customers Above Average Spending #####
### Management wants to identify customers spending more than average.
WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * oi.unit_price) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.customer_name
)

SELECT
    customer_id,
    customer_name,
    ROUND(total_spent, 2) AS total_spent
FROM customer_spending
WHERE total_spent > (
    SELECT AVG(total_spent)
    FROM customer_spending
)
ORDER BY total_spent DESC;

### Analysis 26: Create Sales Summary View ###
## Management needs a reusable sales summary report.## 
CREATE OR REPLACE VIEW sales_summary_view AS
SELECT
    o.order_id,
    o.order_date,
    c.customer_name,
    e.employee_name,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS order_revenue
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN employees e
    ON o.employee_id = e.employee_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    o.order_id,
    o.order_date,
    c.customer_name,
    e.employee_name;

### Analysis 27: Create Index on Orders ####
### Order analysis may become slow as data grows.
CREATE INDEX idx_orders_customer_id
ON orders(customer_id);

SHOW INDEX FROM orders;

### Analysis 28: Monthly Sales Stored Procedure ###
### Management needs a reusable monthly sales report.
DELIMITER //

CREATE PROCEDURE monthly_sales_report()
BEGIN

    SELECT
        YEAR(o.order_date) AS sales_year,
        MONTH(o.order_date) AS sales_month,
        ROUND(
            SUM(oi.quantity * oi.unit_price), 2
        ) AS monthly_revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        YEAR(o.order_date),
        MONTH(o.order_date)

    ORDER BY
        sales_year,
        sales_month;

END //

DELIMITER ;
CALL monthly_sales_report();
SHOW PROCEDURE STATUS
WHERE Db = 'smartmart_retail_sql_project';

## Analysis 29: Customers from Hyderabad and Bangalore ###
### Management wants to combine customers from two key cities.
SELECT customer_id, customer_name, city
FROM customers
WHERE city = 'Hyderabad'

UNION

SELECT customer_id, customer_name, city
FROM customers
WHERE city = 'Bengaluru';

SELECT
    city,
    COUNT(*) AS total_customers
FROM customers
WHERE city IN ('Hyderabad', 'Bengaluru')
GROUP BY city;

SELECT
    city,
    COUNT(*) AS total_customers
FROM customers
GROUP BY city
ORDER BY total_customers DESC;

### Analysis 30: Customers Who Purchased vs Registered Customers ###
### Management wants to compare registered customers and purchasing customers.
SELECT
    customer_id,
    'Registered Customer' AS customer_type
FROM customers

UNION ALL

SELECT
    customer_id,
    'Purchased Customer' AS customer_type
FROM orders; 

SELECT * FROM sales_summary_view;



























































































































































