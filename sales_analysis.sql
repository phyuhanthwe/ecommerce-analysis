select count(*) from sales_data;

-- find top 5 highest selling products in each region
with cte as
(
    select 
        region, 
        product_id, 
        sum(sale_price) as total_sales,
        row_number() over(partition by product_id order by sum(sale_price) desc) as rn
        from sales_data     
        group by product_id, region
)
select region, product_id 
from cte 
where rn < 6;

-- for each category which month had highest sales
with cte as
(
    select 
    category,
    month,
    sum(sale_price) as total_sale,
    row_number() OVER(PARTITION by category order by sum(sale_price) desc) as rn
    from sales_data
    group by category, month
)
select category, month 
from cte
where rn = 1;

-- which sub category had highest growth by profit in 2023 compare to 2022
with cte as
(
    select sub_category,
    extract(YEAR from order_date) as year,
    sum(profit) as total_profit
    from sales_data
    group by sub_category, year
),
cte1 as
(
    SELECT sub_category,
    sum(case when year = 2023 then total_profit else 0 end) as profit_2023,
    sum(case WHEN year = 2022 then total_profit else 0 end) as profit_2022
    from cte
    group by sub_category
)
SELECT 
    sub_category,
    profit_2023,
    profit_2022,
    (profit_2023 - profit_2022) as profit_diff
FROM cte1
order by profit_diff DESC
Limit 1;

-- find month over month growth comparison for 2022 and 2023 sales
with cte as
(
    select month,
    extract(YEAR from order_date) as year,
    sum(sale_price) as total_sales
    from sales_data
    group by month, year
),
cte1 as
(
    SELECT month,
    sum(case when year = 2023 then total_sales else 0 end) as total_sales_2023,
    sum(case WHEN year = 2022 then total_sales else 0 end) as total_sales_2022
    from cte
    group by month
)
SELECT 
    month,
    total_sales_2023,
    total_sales_2022,
    round((((total_sales_2023 - total_sales_2022)/total_sales_2022)*100)::numeric, 2) as growth_percentage
FROM cte1
order by growth_percentage DESC;

-- Calculate the average profit margin (profit / sale) for each product category.
with cte as
(
    SELECT
    category,
    sum(profit)/sum(sale_price) as profit_margin
    FROM sales_data
    GROUP BY category
)
SELECT
category,
round((avg(profit_margin) * 100)::numeric, 2) as avg_profit_margin
from cte
GROUP BY category;

-- Identify the top 3 best-selling products in terms of quantity sold for each quarter of the year.
with cte as(
    SELECT
    product_id,
    extract(year from order_date) as year,
    quarter,
    sum(quantity) as total_quantity,
    row_number() OVER(PARTITION BY extract(year from order_date), quarter, product_id order by sum(quantity) desc) as rn
    from sales_data
    GROUP BY product_id, YEAR, quarter
)
SELECT
product_id,
year,
quarter,
total_quantity
from cte
where rn <=3;