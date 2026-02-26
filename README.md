# Pizza-Sales-Analysis-SQL
# 🍕 Pizza Sales Analysis (SQL)

## 📌 Overview
SQL project analyzing pizza sales to understand revenue, demand patterns, popular sizes, and top-performing categories.

## 🛠 Tools / SQL
- PostgreSQL
- Joins, GROUP BY, aggregates
- Date/time analysis (EXTRACT)
- Window functions (RANK, cumulative revenue)

## 📊 Tables
- pizzas
- pizza_type
- orders
- order_details

## ✅ Analysis Included
- Total orders & total revenue
- Highest priced pizza
- Most common size (by quantity)
- Top 5 pizza types by quantity
- Category-wise quantity distribution
- Orders by hour (peak time)
- Avg pizzas ordered per day
- Top 3 pizzas by revenue
- % revenue contribution by category
- Cumulative revenue trend
- Top 3 pizzas by revenue per category (ranking)

## 🚀 How to Load Data (psql)
If you upload CSVs in `data/`, run:
\copy pizza_type FROM 'data/pizza_types.csv' WITH (FORMAT csv, HEADER true);
\copy pizzas FROM 'data/pizzas.csv' WITH (FORMAT csv, HEADER true);
\copy orders FROM 'data/orders.csv' WITH (FORMAT csv, HEADER true);
\copy order_details FROM 'data/order_details.csv' WITH (FORMAT csv, HEADER true);

## 📌 Notes
- Data loading uses `\copy` to keep the project portable (no personal file paths).
- Dataset upload is optional for portfolio; queries + README are enough.

👨‍💻 Created by: Karan Vaishnav
