use chinook;

-- Q1. Does any table have missing values or duplicates? If yes how would you handle it ? 
-- checking for NULL
SELECT
    COUNT(*) AS total_rows,
    SUM(company IS NULL) AS company_nulls,        /*counts how many rows have company = NULL*/  
    SUM(state IS NULL) AS state_nulls,
    SUM(postal_code IS NULL) AS postal_code_nulls,
    SUM(phone IS NULL) AS phone_nulls,
    SUM(fax IS NULL) AS fax_nulls
FROM customer;
-- 
SELECT
    COUNT(*) AS total_rows,
    SUM(reports_to IS NULL) AS reports_to_nulls  -- reports_to can be NULL because the top-level employee may not report to another employee.
FROM employee;
-- 
SELECT
    COUNT(*) AS total_rows,
    SUM(composer IS NULL) AS composer_nulls  -- This checks how many tracks have no composer information.
FROM track;

-- now checking for duplicates
SELECT
    customer_id,
    COUNT(*) AS occurrence_count
FROM customer
GROUP BY customer_id
HAVING COUNT(*) > 1;
-- 
SELECT
    invoice_id,
    COUNT(*) AS occurrence_count
FROM invoice
GROUP BY invoice_id
HAVING COUNT(*) > 1;

SELECT
    invoice_line_id,
    COUNT(*) AS occurrence_count
FROM invoice_line
GROUP BY invoice_line_id
HAVING COUNT(*) > 1;
-- 
SELECT
    track_id,
    COUNT(*) AS occurrence_count
FROM track
GROUP BY track_id
HAVING COUNT(*) > 1;
--
SELECT
    album_id,
    COUNT(*) AS occurrence_count
FROM album
GROUP BY album_id
HAVING COUNT(*) > 1;
--
SELECT
    artist_id,
    COUNT(*) AS occurrence_count
FROM artist
GROUP BY artist_id
HAVING COUNT(*) > 1;
--
SELECT
    genre_id,
    COUNT(*) AS occurrence_count
FROM genre
GROUP BY genre_id
HAVING COUNT(*) > 1;
--
SELECT
    media_type_id,
    COUNT(*) AS occurrence_count
FROM media_type
GROUP BY media_type_id
HAVING COUNT(*) > 1;
--
SELECT
    playlist_id,
    COUNT(*) AS occurrence_count
FROM playlist
GROUP BY playlist_id
HAVING COUNT(*) > 1;
--
SELECT
    employee_id,
    COUNT(*) AS occurrence_count
FROM employee
GROUP BY employee_id
HAVING COUNT(*) > 1;
--
SELECT
    playlist_id,
    track_id,
    COUNT(*) AS occurrence_count
FROM playlist_track
GROUP BY playlist_id, track_id
HAVING COUNT(*) > 1;

-- Checking for duplicate complete rows(checks whether the same complete record appears more than once.)
SELECT
    first_name,
    last_name,
    company,
    address,
    city,
    state,
    country,
    postal_code,
    phone,
    fax,
    email,
    support_rep_id,
    COUNT(*) AS duplicate_count
FROM customer
GROUP BY
    first_name,
    last_name,
    company,
    address,
    city,
    state,
    country,
    postal_code,
    phone,
    fax,
    email,
    support_rep_id
HAVING COUNT(*) > 1;  /* no duplicates found*/
-- --
SELECT
    customer_id,
    first_name,
    last_name,
    COALESCE(company, 'Not Provided') AS company
FROM customer;

-- Q2.Find the top top-selling tracks and top artist in the USA and identify their most famous genres. 
-- Top-selling tracks in the USA
SELECT
    t.track_id,
    t.name AS track_name,
    ar.name AS artist_name,
    g.name AS genre,
    SUM(il.quantity) AS units_sold,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue
FROM invoice i
JOIN invoice_line il
    ON i.invoice_id = il.invoice_id
JOIN track t
    ON il.track_id = t.track_id
JOIN album al
    ON t.album_id = al.album_id
JOIN artist ar
    ON al.artist_id = ar.artist_id
JOIN genre g
    ON t.genre_id = g.genre_id
WHERE i.billing_country = 'USA'
GROUP BY t.track_id,t.name,ar.name,g.name
ORDER BY
    units_sold DESC,
    revenue DESC
LIMIT 10;

-- Find the top-selling artist in the USA
SELECT
    ar.artist_id,
    ar.name AS artist_name,
    SUM(il.quantity) AS units_sold,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue
FROM invoice i
JOIN invoice_line il
    ON i.invoice_id = il.invoice_id
JOIN track t
    ON il.track_id = t.track_id
JOIN album al
    ON t.album_id = al.album_id
JOIN artist ar
    ON al.artist_id = ar.artist_id
WHERE i.billing_country = 'USA'
GROUP BY
    ar.artist_id,
    ar.name
ORDER BY
    units_sold DESC,
    revenue DESC
LIMIT 1;

-- 3. Identify the most famous genre of the top artist
SELECT
    g.name AS genre,
    SUM(il.quantity) AS units_sold,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue
FROM invoice i
JOIN invoice_line il
    ON i.invoice_id = il.invoice_id
JOIN track t
    ON il.track_id = t.track_id
JOIN album al
    ON t.album_id = al.album_id
JOIN artist ar
    ON al.artist_id = ar.artist_id
JOIN genre g
    ON t.genre_id = g.genre_id
WHERE i.billing_country = 'USA'
  AND ar.name = 'Van Halen'
GROUP BY g.genre_id, g.name
ORDER BY units_sold DESC
LIMIT 1;

-- Q3.What is the customer demographic breakdown (age, gender, location) of Chinook's customer base?
--  Age and gender breakdown

describe customer;

-- locatoin breakdown
SELECT
    country,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customer),2
    ) AS percentage_of_customers
FROM customer
GROUP BY country
ORDER BY customer_count DESC;

-- Q4. Calculate the total revenue and number of invoices for each country, state, and city
-- Revenue and invoices by Country
SELECT
    billing_country AS country,
    ROUND(SUM(total), 2) AS total_revenue,   /*adds the value of all invoices for each country.*/
    COUNT(invoice_id) AS number_of_invoices  /*counts the number of invoices for that country.*/
FROM invoice
GROUP BY billing_country         /*creates one group for every country.*/
ORDER BY total_revenue DESC;

-- Revenue and invoices by State
SELECT
    billing_country AS country,
    billing_state AS state,
    ROUND(SUM(total), 2) AS total_revenue,
    COUNT(invoice_id) AS number_of_invoices
FROM invoice
GROUP BY
    billing_country,
    billing_state
ORDER BY
    total_revenue DESC;
    
--  Revenue and invoices by City
SELECT
    billing_country AS country,
    billing_state AS state,
    billing_city AS city,
    ROUND(SUM(total), 2) AS total_revenue,
    COUNT(invoice_id) AS number_of_invoices
FROM invoice
GROUP BY
    billing_country,
    billing_state,
    billing_city
ORDER BY
    total_revenue DESC;

-- Top 5 customers by total revenue in each country

WITH customer_revenue AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.country,
        SUM(i.total) AS total_revenue
    FROM customer c
    JOIN invoice i
        ON c.customer_id = i.customer_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name,
        c.country
),
ranked_customers AS (
    SELECT
        customer_id,
        customer_name,
        country,
        ROUND(total_revenue, 2) AS total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY country
            ORDER BY total_revenue DESC
        ) AS customer_rank
    FROM customer_revenue
)
SELECT
    country,
    customer_rank,
    customer_id,
    customer_name,
    total_revenue
FROM ranked_customers
WHERE customer_rank <= 5
ORDER BY
    country,
    customer_rank;

-- top-selling track for each customer

SELECT customer_id, customer_name, track_name, units_sold
FROM (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        t.name AS track_name,
        SUM(il.quantity) AS units_sold,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_id
            ORDER BY SUM(il.quantity) DESC
        ) AS rn
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    GROUP BY c.customer_id, c.first_name, c.last_name, t.track_id, t.name
) x
WHERE rn = 1;

-- Q7 

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(i.invoice_id) AS purchase_frequency,
    ROUND(AVG(i.total), 2) AS average_order_value,
    ROUND(SUM(i.total), 2) AS total_spent
FROM customer c
JOIN invoice i
    ON c.customer_id = i.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY
    purchase_frequency DESC,
    average_order_value DESC;

-- Q8
WITH last_purchase AS (
    SELECT
        c.customer_id,
        MAX(i.invoice_date) AS last_purchase_date
    FROM customer c
    LEFT JOIN invoice i
        ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
)
SELECT
    ROUND(
        SUM(
            CASE
                WHEN last_purchase_date < DATE_SUB(
                    (SELECT MAX(invoice_date) FROM invoice),
                    INTERVAL 6 MONTH
                )
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM last_purchase;

-- Q9 Percentage of total sales by genre in the USA

SELECT
    g.name AS genre,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS total_sales,
    ROUND(
        SUM(il.unit_price * il.quantity) * 100.0 /
        (
            SELECT SUM(il2.unit_price * il2.quantity)
            FROM invoice i2
            JOIN invoice_line il2
                ON i2.invoice_id = il2.invoice_id
            WHERE i2.billing_country = 'USA'
        ),
        2
    ) AS sales_percentage
FROM invoice i
JOIN invoice_line il
    ON i.invoice_id = il.invoice_id
JOIN track t
    ON il.track_id = t.track_id
JOIN genre g
    ON t.genre_id = g.genre_id
WHERE i.billing_country = 'USA'
GROUP BY g.name
ORDER BY total_sales DESC;

-- Best-selling artists in the USA

SELECT
    ar.name AS artist,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS total_sales
FROM invoice i
JOIN invoice_line il
    ON i.invoice_id = il.invoice_id
JOIN track t
    ON il.track_id = t.track_id
JOIN album al
    ON t.album_id = al.album_id
JOIN artist ar
    ON al.artist_id = ar.artist_id
WHERE i.billing_country = 'USA'
GROUP BY ar.name
ORDER BY total_sales DESC
LIMIT 10;

--  Q10 customers who have purchased tracks from at least 3 different+ genres
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(DISTINCT t.genre_id) AS number_of_genres
FROM customer c
JOIN invoice i
    ON c.customer_id = i.customer_id
JOIN invoice_line il
    ON i.invoice_id = il.invoice_id
JOIN track t
    ON il.track_id = t.track_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
HAVING COUNT(DISTINCT t.genre_id) >= 3
ORDER BY number_of_genres DESC;

-- Q11 
SELECT
    g.name AS genre,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS total_sales,
    RANK() OVER (
        ORDER BY SUM(il.unit_price * il.quantity) DESC
    ) AS genre_rank
FROM invoice i
JOIN invoice_line il
    ON i.invoice_id = il.invoice_id
JOIN track t
    ON il.track_id = t.track_id
JOIN genre g
    ON t.genre_id = g.genre_id
WHERE i.billing_country = 'USA'
GROUP BY g.genre_id, g.name
ORDER BY genre_rank;

-- 	Q12
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    MAX(i.invoice_date) AS last_purchase_date
FROM customer c
LEFT JOIN invoice i
    ON c.customer_id = i.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
HAVING MAX(i.invoice_date) < DATE_SUB(
    (SELECT MAX(invoice_date) FROM invoice),
    INTERVAL 3 MONTH
)
ORDER BY last_purchase_date;

-- Q12 part 2 
SELECT
    customer_status,
    COUNT(*) AS customer_count
FROM (
    SELECT
        CASE
            WHEN MAX(i.invoice_date) < DATE_SUB(
                (SELECT MAX(invoice_date) FROM invoice),
                INTERVAL 3 MONTH
            )
            THEN 'Inactive'
            ELSE 'Active'
        END AS customer_status
    FROM customer c
    LEFT JOIN invoice i
        ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
) AS customer_status_table
GROUP BY customer_status
ORDER BY customer_status;

-- SQ1

SELECT
    al.title AS album,
    ar.name AS artist,
    g.name AS genre,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue
FROM invoice_line il
JOIN invoice i
    ON il.invoice_id = i.invoice_id
JOIN track t
    ON il.track_id = t.track_id
JOIN album al
    ON t.album_id = al.album_id
JOIN artist ar
    ON al.artist_id = ar.artist_id
JOIN genre g
    ON t.genre_id = g.genre_id
WHERE i.billing_country = 'USA'
GROUP BY
    al.album_id,
    al.title,
    ar.name,
    g.name
ORDER BY revenue DESC
LIMIT 3;

-- Q2

WITH genre_sales AS (
    SELECT
        i.billing_country AS country,
        g.name AS genre,
        ROUND(SUM(il.unit_price * il.quantity), 2) AS total_sales
    FROM invoice i
    JOIN invoice_line il
        ON i.invoice_id = il.invoice_id
    JOIN track t
        ON il.track_id = t.track_id
    JOIN genre g
        ON t.genre_id = g.genre_id
    WHERE i.billing_country <> 'USA'
    GROUP BY i.billing_country, g.genre_id, g.name
),

ranked_genres AS (
    SELECT
        country,
        genre,
        total_sales,
        RANK() OVER (
            PARTITION BY country
            ORDER BY total_sales DESC
        ) AS genre_rank
    FROM genre_sales
)

SELECT
    country,
    genre,
    total_sales,
    genre_rank
FROM ranked_genres
WHERE genre_rank <= 3
ORDER BY country, genre_rank;

-- Q3 Build customer purchase history
WITH customer_history AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        MIN(i.invoice_date) AS first_purchase_date,
        MAX(i.invoice_date) AS last_purchase_date,
        COUNT(DISTINCT i.invoice_id) AS total_orders,
        SUM(i.total) AS total_spending
    FROM customer c
    JOIN invoice i
        ON c.customer_id = i.customer_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
)

SELECT
    customer_id,
    customer_name,
    first_purchase_date,
    last_purchase_date,
    DATEDIFF(last_purchase_date, first_purchase_date) AS customer_lifetime_days,
    total_orders,
    ROUND(total_spending, 2) AS total_spending
FROM customer_history
ORDER BY customer_lifetime_days DESC;

-- Q3(2)
WITH customer_history AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        MIN(i.invoice_date) AS first_purchase_date,
        MAX(i.invoice_date) AS last_purchase_date,
        COUNT(DISTINCT i.invoice_id) AS total_orders,
        SUM(i.total) AS total_spending
    FROM customer c
    JOIN invoice i
        ON c.customer_id = i.customer_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
),

customer_segments AS (
    SELECT
        *,
        DATEDIFF(last_purchase_date, first_purchase_date) AS lifetime_days,
        CASE
            WHEN DATEDIFF(last_purchase_date, first_purchase_date) <= 365
                THEN 'New Customer'
            ELSE 'Long-Term Customer'
        END AS customer_type
    FROM customer_history
)

SELECT
    customer_type,
    COUNT(*) AS number_of_customers,
    ROUND(AVG(total_orders), 2) AS avg_purchase_frequency,
    ROUND(AVG(total_spending), 2) AS avg_total_spending,
    ROUND(AVG(total_spending / NULLIF(total_orders, 0)), 2) AS avg_basket_size
FROM customer_segments
GROUP BY customer_type;

-- Q4(1)

WITH invoice_genres AS (
    SELECT DISTINCT
        il.invoice_id,
        t.genre_id,
        g.name AS genre
    FROM invoice_line il
    JOIN track t
        ON il.track_id = t.track_id
    JOIN genre g
        ON t.genre_id = g.genre_id
)

SELECT
    g1.genre AS genre_1,
    g2.genre AS genre_2,
    COUNT(*) AS times_purchased_together
FROM invoice_genres g1
JOIN invoice_genres g2
    ON g1.invoice_id = g2.invoice_id
   AND g1.genre_id < g2.genre_id
GROUP BY
    g1.genre_id,
    g1.genre,
    g2.genre_id,
    g2.genre
ORDER BY
    times_purchased_together DESC;
    
    -- Q4(2)
    WITH invoice_artists AS (
    SELECT DISTINCT
        il.invoice_id,
        ar.artist_id,
        ar.name AS artist
    FROM invoice_line il
    JOIN track t
        ON il.track_id = t.track_id
    JOIN album al
        ON t.album_id = al.album_id
    JOIN artist ar
        ON al.artist_id = ar.artist_id
)

SELECT
    a1.artist AS artist_1,
    a2.artist AS artist_2,
    COUNT(*) AS times_purchased_together
FROM invoice_artists a1
JOIN invoice_artists a2
    ON a1.invoice_id = a2.invoice_id
   AND a1.artist_id < a2.artist_id
GROUP BY
    a1.artist_id,
    a1.artist,
    a2.artist_id,
    a2.artist
ORDER BY
    times_purchased_together DESC
LIMIT 20;

-- Q4(3)

WITH invoice_albums AS (
    SELECT DISTINCT
        il.invoice_id,
        al.album_id,
        al.title AS album
    FROM invoice_line il
    JOIN track t
        ON il.track_id = t.track_id
    JOIN album al
        ON t.album_id = al.album_id
)

SELECT
    a1.album AS album_1,
    a2.album AS album_2,
    COUNT(*) AS times_purchased_together
FROM invoice_albums a1
JOIN invoice_albums a2
    ON a1.invoice_id = a2.invoice_id
   AND a1.album_id < a2.album_id
GROUP BY
    a1.album_id,
    a1.album,
    a2.album_id,
    a2.album
ORDER BY
    times_purchased_together DESC
LIMIT 20;

-- Q4(4)

WITH invoice_genres AS (
    SELECT DISTINCT
        il.invoice_id, t.genre_id, g.name AS genre
    FROM invoice_line il
    JOIN track t
        ON il.track_id = t.track_id
    JOIN genre g
        ON t.genre_id = g.genre_id),
genre_pairs AS (
    SELECT
        g1.genre AS genre_1,
        g2.genre AS genre_2,
        COUNT(*) AS invoices_together
    FROM invoice_genres g1
    JOIN invoice_genres g2
        ON g1.invoice_id = g2.invoice_id
       AND g1.genre_id < g2.genre_id
    GROUP BY g1.genre_id, g1.genre, g2.genre_id, g2.genre)
SELECT
    genre_1, genre_2, invoices_together,
    ROUND(invoices_together * 100.0 /
        (SELECT COUNT(*) FROM invoice),
        2 ) AS support_percentage
FROM genre_pairs
ORDER BY invoices_together DESC;
-- Q5

WITH customer_metrics AS (
    SELECT
        c.customer_id, c.country,
        COUNT(i.invoice_id) AS purchase_frequency,
        COALESCE(SUM(i.total), 0) AS total_spending,
        MAX(i.invoice_date) AS last_purchase_date
    FROM customer c
    LEFT JOIN invoice i
        ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.country
),
regional_analysis AS (
    SELECT country,
        COUNT(*) AS customer_count,
        ROUND(AVG(purchase_frequency), 2) AS avg_purchase_frequency,
        ROUND(AVG(total_spending), 2) AS avg_customer_spending,
		SUM(
            CASE
                WHEN last_purchase_date <
                     DATE_SUB(
                         (SELECT MAX(invoice_date) FROM invoice),INTERVAL 3 MONTH) THEN 1 ELSE 0
            END
        ) AS churned_customers
	FROM customer_metrics
    GROUP BY country)
SELECT country, customer_count, avg_purchase_frequency, avg_customer_spending, churned_customers,
    ROUND(churned_customers * 100.0 / customer_count,2) AS churn_rate_percentage
FROM regional_analysis
ORDER BY churn_rate_percentage DESC;

-- Q6
WITH customer_metrics AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.country, c.city,
        COUNT(i.invoice_id) AS purchase_frequency,
        ROUND(SUM(i.total), 2) AS total_spending,
        MAX(i.invoice_date) AS last_purchase_date,
        MIN(i.invoice_date) AS first_purchase_date
    FROM customer c
    LEFT JOIN invoice i
        ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name,
        c.country, c.city
),
risk_profile AS (
    SELECT *,
        DATEDIFF((SELECT MAX(invoice_date) FROM invoice),last_purchase_date) AS days_since_last_purchase,
		DATEDIFF(last_purchase_date,first_purchase_date) AS customer_lifetime_days
    FROM customer_metrics
)
SELECT
    customer_id, customer_name,
    country, city,
    purchase_frequency, total_spending,
    last_purchase_date,
    days_since_last_purchase,
    customer_lifetime_days,
	CASE
        WHEN days_since_last_purchase > 90
             AND purchase_frequency <= 5
            THEN 'High Risk'
            WHEN days_since_last_purchase > 60
             OR purchase_frequency <= 3
            THEN 'Medium Risk'
            ELSE 'Low Risk'
    END AS risk_segment
FROM risk_profile
ORDER BY
    CASE
        WHEN days_since_last_purchase > 90
             AND purchase_frequency <= 5
            THEN 1
        WHEN days_since_last_purchase > 60
             OR purchase_frequency <= 3
            THEN 2
        ELSE 3
    END,
    total_spending DESC;
    
-- Q7 

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) AS tenure_days,
    COUNT(i.invoice_id) AS purchase_frequency,
    ROUND(SUM(i.total), 2) AS total_spending,
    ROUND(AVG(i.total), 2) AS avg_purchase_value,
    DATEDIFF(
        (SELECT MAX(invoice_date) FROM invoice),
        MAX(i.invoice_date)
    ) AS days_since_last_purchase,
    CASE
        WHEN SUM(i.total) >= 100 AND COUNT(i.invoice_id) >= 10
             AND DATEDIFF((SELECT MAX(invoice_date) FROM invoice),
                          MAX(i.invoice_date)) <= 90
        THEN 'High Value - Active'
        WHEN SUM(i.total) >= 90
             AND DATEDIFF((SELECT MAX(invoice_date) FROM invoice),
                          MAX(i.invoice_date)) > 90
        THEN 'High Value - At Risk'
        WHEN DATEDIFF((SELECT MAX(invoice_date) FROM invoice),
                      MAX(i.invoice_date)) > 90
        THEN 'Inactive'
        ELSE 'Regular'
    END AS customer_segment
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spending DESC;

describe album;

ALTER TABLE album
ADD COLUMN ReleaseYear INTEGER;


-- Q11
use chinook;
WITH customer_spending AS (
    SELECT customer_id,
        SUM(total) AS total_spent
    FROM invoice
    GROUP BY customer_id
),
customer_tracks AS (
    SELECT i.customer_id,
        SUM(il.quantity) AS tracks_purchased
    FROM invoice i
    JOIN invoice_line il
        ON i.invoice_id = il.invoice_id
    GROUP BY i.customer_id
)
SELECT
    c.country,
    COUNT(DISTINCT c.customer_id) AS number_of_customers,
    ROUND(AVG(cs.total_spent), 2) AS average_total_spent,
    ROUND(AVG(ct.tracks_purchased), 2) AS average_tracks_purchased
FROM customer c
JOIN customer_spending cs
    ON c.customer_id = cs.customer_id
JOIN customer_tracks ct
    ON c.customer_id = ct.customer_id
GROUP BY c.country
ORDER BY average_total_spent DESC;