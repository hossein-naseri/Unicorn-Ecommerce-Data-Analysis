/* Question #1:
How many customers do we have in the data? */

SELECT COUNT(customer_id) AS total_customers -- since customer_id is primary key then it doesn't matter to use distinct or not
FROM customers;



-----------------------------------------------------------------
/* Question #2:
What was the city with the most profit for the company in 2015?

Question #3:
In 2015, what was the most profitable city's profit?*/

SELECT
		shipping_city,
    SUM(order_profits) AS total_profit
    
FROM orders
		INNER JOIN order_details
    USING(order_id)
    
WHERE EXTRACT(YEAR FROM shipping_date) = '2015'

GROUP BY 1

ORDER BY 2 DESC

LIMIT 1;
    


-----------------------------------------------------------------
/* Question #4:
How many different cities do we have in the data? */

SELECT COUNT(DISTINCT shipping_city)
FROM orders;



-----------------------------------------------------------------
/* Question #5:
Show the total spent by customers from low to high. */

SELECT
		c.customer_id,
    SUM(order_sales) AS total_spent
    
FROM customers AS c 
    LEFT JOIN orders AS o -- customer table and left join are used to show potential customers who have not made a purchase yer (0 total_spent)
    USING(customer_id)
    INNER JOIN order_details AS od
    USING(order_id)
    
GROUP BY 1

ORDER BY 2
;



-----------------------------------------------------------------
/* Question #6:
What is the most profitable city in the State of Tennessee? */

SELECT
		shipping_city,
    SUM(order_profits) AS total_profit
    
FROM orders
		INNER JOIN order_details
    USING(order_id)
    
WHERE shipping_state = 'Tennessee'

GROUP BY 1

ORDER BY 2 DESC

LIMIT 1;



-----------------------------------------------------------------
/* Question #7:
What’s the average annual profit for that city across all years? */

SELECT
		shipping_city,
		ROUND( (SUM(order_profits) / COUNT(DISTINCT EXTRACT (YEAR FROM shipping_date)))::NUMERIC, 2) AS annual_profit
    
FROM orders
		INNER JOIN order_details
    USING(order_id)
    
WHERE shipping_city IN ( -- Instead of hardcoding the name of the city, this subquery is used to find the most profitable city in tennesy which might change over years 
                        SELECT
                            shipping_city

                        FROM orders
                            INNER JOIN order_details
                            USING(order_id)

                        WHERE shipping_state = 'Tennessee'

                        GROUP BY 1

                        ORDER BY SUM(order_profits) DESC

                        LIMIT 1)
                        
GROUP BY 1
;



-----------------------------------------------------------------
/* Question #8:
What is the distribution of customer types in the data? */

SELECT
		customer_segment,
    COUNT (customer_id) AS total_customers

FROM customers

GROUP BY 1
ORDER BY 2 DESC;



-----------------------------------------------------------------
/* Question #9:
What’s the most profitable product category on average in Iowa across all years? */

WITH profit_over_category_and_year AS (

  SELECT
      EXTRACT (YEAR FROM order_date) AS year_, -- for the sake of challenge and also providing additional info, top performing category is calculated per each year.
      product_category,
      SUM(order_profits) AS total_profit

  FROM product
      JOIN order_details
      USING(product_id)
      JOIN orders
      USING (order_id)

  WHERE shipping_state = 'Iowa'

  GROUP BY 1,2
),

top_profit AS (
  
  SELECT
      *,
      MAX(total_profit) OVER(PARTITION BY year_) AS max_profit_in_year

  FROM profit_over_category_and_year
)


SELECT
		year_,
    product_category AS top_performing_category_in_Iowa
    
FROM top_profit

WHERE max_profit_in_year = total_profit
;



-----------------------------------------------------------------
/* Question #10:
What is the most popular product in that category across all states in 2016? */

SELECT product_name

FROM product
          JOIN order_details
          USING(product_id)
          JOIN orders
          USING (order_id)

WHERE EXTRACT (YEAR FROM order_date) = '2016'
		AND product_category = ( 
      -- Since in the previous question top performing category for Iowa is calculated for each year separately and also because the result might change over time, this subquery is added to find the category accross all years.

                            SELECT product_category

                            FROM product
                                JOIN order_details
                                USING(product_id)
                                JOIN orders
                                USING (order_id)

                            WHERE shipping_state = 'Iowa'

                            GROUP BY 1

                            ORDER BY SUM(order_profits) DESC

                            LIMIT 1
                            )
                            
GROUP BY 1

ORDER BY SUM(order_profits) DESC

LIMIT 1
;



-----------------------------------------------------------------
/* Question #11:
Which customer got the most discount in the data? (in total amount) */

SELECT
		c.customer_id,
		ROUND(SUM(order_sales * order_discount / (1 - order_discount))) AS total_discount -- Since the info is not provided, I assumed that order_sales is the price that the customer paid after the discount is applied (order_sales = [1 - order_discount] * full_price), therefore for calculating the discount amount this calculation is necessary:

FROM customers AS c
		JOIN orders AS o
    USING(customer_id)
    JOIN order_details AS od
    USING(order_id)
    
GROUP BY 1

ORDER BY 2 DESC

LIMIT 1
;
    


-----------------------------------------------------------------
/* Question #12:
How widely did monthly profits vary in 2018? */

SELECT
		TO_CHAR (order_date, 'Mon') AS months_in_2018,
		SUM (order_profits) AS total_profit

FROM order_details
		JOIN orders
    USING (order_id)
    
WHERE EXTRACT (YEAR FROM order_date) = 2018

GROUP BY 1,EXTRACT (MONTH FROM order_date)

ORDER BY EXTRACT (MONTH FROM order_date)
;



-----------------------------------------------------------------
/* Question #13:
Which was the biggest order regarding sales in 2015? */

SELECT
		order_id,
    SUM (order_sales) AS total_sales
    
FROM orders
		JOIN order_details
    USING (order_id)
    
WHERE EXTRACT (YEAR FROM order_date) = 2015

GROUP BY 1

ORDER BY 2 DESC

LIMIT 1
;



-----------------------------------------------------------------
/* Question #14:
What was the rank of each city in the East region in 2015 in quantity? */

SELECT
    shipping_city AS city,
    RANK () OVER (ORDER BY SUM (quantity) DESC) AS rank_

FROM
		order_details
    JOIN orders
    USING (order_id)

WHERE
		shipping_region = 'East'
    AND EXTRACT (YEAR FROM order_date) = 2015

GROUP BY 1
;



-----------------------------------------------------------------
/* Question #15:
Display customer names for customers who are in the segment ‘Consumer’ or ‘Corporate.’ How many customers are there in total? */

SELECT
		customer_name,
    COUNT (*) OVER() AS total_customers_in_Consumer_and_Corporate_segments
    
FROM customers

WHERE customer_segment IN ('Consumer', 'Corporate')
;



-----------------------------------------------------------------
/* Question #16:
Calculate the difference between the largest and smallest order quantities for product id ‘100.’ */

SELECT
		MAX(quantity) - MIN(quantity) AS difference

FROM order_details

WHERE product_id = '100'
;



-----------------------------------------------------------------
/* Question #17:
Calculate the percent of products that are within the category ‘Furniture.’ */

SELECT
    ROUND(100.0 *	AVG(CASE WHEN product_category = 'Furniture' THEN 1 ELSE 0 END), 2) AS proportion_pct
    
FROM product
;



-----------------------------------------------------------------
/* Question #18:
Display the number of product manufacturers with more than 1 product in the product table. */

SELECT product_manufacturer

FROM product

GROUP BY product_manufacturer

HAVING COUNT(product_id) > 1
;



-----------------------------------------------------------------
/* Question #19:
Show the product_subcategory and the total number of products in the subcategory.
Show the order from most to least products and then by product_subcategory name ascending. */

SELECT
		product_subcategory,
    COUNT(product_id) AS total_products
    
FROM product

GROUP BY 1

ORDER BY 2 DESC, 1
;



-----------------------------------------------------------------
/* Question #20:
Show the product_id(s), the sum of quantities, where the total sum of its
product quantities are greater than or equal to 100. */

SELECT
		product_id,
    SUM(quantity) AS total_quantities
    
FROM order_details

GROUP BY 1

HAVING SUM(quantity) >= 100

ORDER BY 2 DESC
;



