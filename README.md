# sql-data-analysis-project
SQL project gor sales and customer behavior analysis

## Project Overview

This project focuses on developing analytical SQL queries to explore an e-commerce database, extract business insights, analyze customer behavior, evaluate product performance, and assess data quality.

The project is designed to demonstrate practical SQL skills through business-oriented analytical questions and real-world use cases.

**Note:** This project uses a hypothetical database schema for SQL analysis practice. It does not represent actual business data or verified business findings.

## Database Schema

The project consists of four relational tables:

| Table | Description |
|---|---|
| `users` | User information, registration dates, and countries |
| `orders` | Order dates, user IDs, and total order amounts |
| `order_items` | Products, quantities, and prices associated with each order |
| `products` | Product categories and creation dates |

## Project Sections

### 1. Data Exploration
- Counting users, orders, and products
- Exploring the order date range
- Identifying countries with a small share of users
- Finding registered users without purchases

### 2. Key Sales Metrics
- Calculating total revenue
- Analyzing monthly revenue
- Calculating Average Order Value (AOV)
- Measuring average revenue per user
- Analyzing revenue contribution by country

### 3. Customer Behavior Analysis
- Calculating orders per user
- Identifying one-time and repeat customers
- Measuring time intervals between purchases
- Finding the top 10 highest-spending users
- Analyzing purchase frequency distribution

### 4. Product Analysis
- Calculating revenue by product
- Analyzing revenue by product category
- Identifying products with no sales
- Finding the top 5 best-selling products
- Identifying recently added products without sales

### 5. Time-Based Analysis
- Analyzing monthly revenue trends
- Calculating average daily revenue
- Identifying the best and worst sales days
- Comparing weekend and weekday revenue
- Calculating month-over-month revenue changes

### 6. Advanced SQL Analysis
- Calculating cumulative revenue
- Ranking users by revenue
- Measuring revenue contribution of the top 20% of users
- Identifying first and last purchase dates
- Calculating customer lifetime value (LTV)

### 7. Customer and Product Segmentation
- Segmenting users based on lifetime value
- Applying ABC analysis to products
- Measuring revenue contribution by product segment
- Identifying VIP users within each country

### 8. Data Quality and Validation
- Finding orders without valid users
- Identifying orders without order items
- Detecting invalid quantities and prices
- Comparing order totals with item-level totals
- Identifying suspicious registration and order dates
- Finding products with missing categories
- Detecting order items linked to invalid products
- Identifying potentially duplicate orders

## SQL Skills Demonstrated

- Filtering and sorting (`WHERE`, `HAVING`, `ORDER BY`)
- Aggregations (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`)
- Joins (`INNER JOIN`, `LEFT JOIN`)
- Subqueries and Common Table Expressions (CTEs)
- Window Functions (`LAG`, `DENSE_RANK`, `ROW_NUMBER`, `NTILE`)
- Date and time functions
- Conditional logic (`CASE WHEN`)
- Customer and product segmentation
- Data quality checks

## Tools

- MySQL
- SQL
- MySQL Workbench / DBeaver

## Project Objective

The main objective is to strengthen practical SQL skills and demonstrate the ability to translate business questions into analytical queries.

This project serves as a SQL portfolio project for a Data Analyst career path.
