Chinook Music Store: SQL Customer and Sales Analysis

A SQL-based business analysis of the Chinook digital music store database (MySQL). The project covers data quality checks, sales and revenue analysis, customer behaviour, churn and risk profiling, product affinity, and regional market insights, and ends with actionable recommendations for marketing, retention and cross-selling.

Table of Contents
Project Overview
Database Schema
Tools and SQL Techniques
Project Structure
Part 1: Objective Analysis
Part 2: Subjective Analysis
Key Findings
Business Recommendations
Assumptions and Limitations
How to Run
Project Overview

Chinook is a fictional digital music store. This project answers 11 objective and 11 subjective business questions to help the store:

Understand which tracks, artists and genres sell best, especially in the USA
Profile its customers by location, spending and purchase frequency
Measure churn and identify customers at risk of leaving
Find products that are bought together for cross-selling
Compare regional markets and decide where to focus marketing
Database Schema

The analysis uses these Chinook tables:

Table	Purpose
customer	Customer profile and location
employee	Staff and reporting hierarchy
invoice	Order header (date, billing location, total)
invoice_line	Order line items (unit price, quantity)
track	Individual tracks
album	Albums
artist	Artists
genre	Music genres
media_type	File formats
playlist, playlist_track	Playlists and their tracks

Sales path: invoice → invoice_line → track → album → artist, with genre linked through track.

Tools and SQL Techniques
Database: MySQL
Joins: multi-table joins across the sales path
Aggregation: SUM, COUNT, COUNT(DISTINCT ...), AVG, MAX, GROUP BY, HAVING
Window functions: ROW_NUMBER(), RANK() with PARTITION BY
Date logic: DATE_SUB() against the latest invoice date
Null handling: COALESCE()
DDL: ALTER TABLE
Visuals: bar, scatter and other charts built from query outputs
Project Structure
chinook-sql-analysis/
├── README.md
├── sql/
│   ├── objective_questions.sql
│   └── subjective_questions.sql
├── report/
│   └── Chinook_Project_Report.docx
└── images/
    └── (query outputs and charts)

Adjust this layout to match your repository.

Part 1: Objective Analysis
#	Question	Approach
1	Missing values and duplicates	Checked NULLs (company, reports_to, composer) and primary-key duplicates; NULLs kept because they can be valid, with COALESCE() used for reporting
2	Top tracks and artist in the USA, and their genres	SUM(quantity) across the sales path, filtered to billing_country = 'USA'
3	Customer demographics	Location only; age and gender are not in the data
4	Revenue and invoices by country, state and city	Grouped by the full geographic hierarchy
5	Top 5 customers by revenue in each country	ROW_NUMBER() partitioned by country
6	Top-selling track per customer	Ranking window function, keeping rank 1
7	Purchasing patterns	Purchase frequency, average order value, total spend
8	Customer churn rate	Churned if no purchase for 6+ months before the latest invoice date
9	Genre share of USA sales; best genres and artists	Revenue = UnitPrice × Quantity
10	Customers buying from 3+ genres	COUNT(DISTINCT genre_id) with HAVING
11	Genre ranking in the USA	RANK() over total revenue
12	Customers inactive for 3 months	Relative to the latest invoice date, not today's date
Part 2: Subjective Analysis
#	Topic	Summary
1	Albums to promote in the USA	Based on genre sales, focusing on top USA genres
2	Top genres outside the USA	Top 3 genres per country, compared with the USA
3	Long-term vs new customers	Compared frequency, basket size and spend (12-month cutoff)
4	Product affinity	Genres, artists and albums bought together in the same invoice
5	Regional market analysis	Revenue, activity and churn by country
6	Customer risk profiling	High, medium and low risk by recency, frequency and spend
7	Customer lifetime value	Segments by spend, frequency and recency
8	Promotion impact framework	KPIs and formulas for when campaign data exists
9	Approach without predefined questions	End-to-end analytics lifecycle
10	Schema change	Add ReleaseYear INTEGER to album
11	Spend by country	Average spend, customer count and tracks per customer
Key Findings

Sales and genres (USA)

Top-selling track: War Pigs (Cake, Alternative), 6 units.
Top-selling artist: Van Halen, 43 units, with Rock as their strongest genre.
Rock is the best-selling genre by revenue ($568.75 in the objective analysis), followed by Alternative & Punk and Metal.
TV Shows, Soundtrack and Classical are among the weakest genres.
Albums suggested for promotion: From the Muddy Banks of the Wishkah, Are You Experienced? and The Best Of Van Halen, Vol. 1.

Geography

The USA generates the highest revenue, followed by Canada and Brazil.
Rock appears among the top genres in many countries, while second and third places vary (for example Latin, Metal, Alternative & Punk).
The USA has the largest customer base (13 customers, average spend $80.04).
The Czech Republic has the highest average spend ($136.62) but only 2 customers.

Customer behaviour and retention

Some customers buy from 12 to 14 different genres, a sign of very diverse tastes.
Churn is high in Germany (75%) and Brazil (60%), even though their customers spend well; the USA is lower at about 23.08%.
Inactive customers are the second-highest spending segment, so the store is losing valuable customers.
High-value customers with long inactivity (for example Manoj Pareek and François Tremblay) are priority re-engagement targets.

Product affinity

Strongest genre pair: Rock and Metal, in 268 invoices (43.65% support).
Strongest artist pair: Led Zeppelin and Green Day (19 invoices).
Strongest album pair: Are You Experienced? and Mezmerize (14 invoices).
Business Recommendations
Promote high-performing genres (Rock, Alternative & Punk, Metal) in the USA, and tailor campaigns by country.
Cross-sell Rock and Metal, and offer discounted bundles for frequently paired albums.
Run retention campaigns in high-value, high-churn markets such as Germany and Brazil.
Re-engage high-value inactive customers with personalised offers based on their purchase history.
Reward loyal customers with loyalty programmes and early access, and offer new customers a second-purchase incentive.
Track recency and frequency regularly to spot at-risk customers before they leave.
Evaluate smaller high-value markets (Czech Republic, Ireland) for expansion, keeping sample size in mind.
Assumptions and Limitations
Age and gender are not in the Chinook customer table, so demographic analysis is limited to location.
Payment method data is not available, so payment preferences could not be analysed.
Churn is defined by inactivity (6 months for churn rate, 3 months for the inactive list), measured against the latest invoice date in the dataset, since the data is historical.
Long-term vs new customers uses a 12-month cutoff, which is an analytical assumption.
Risk and CLV segments are rule-based classifications on historical data, not predicted probabilities.
Promotion impact cannot be measured because the database has no campaign data; Subjective Q8 provides a framework (uplift, retention, ROI, treatment vs control) for when such data is available.
Countries with very few customers can produce misleading averages and churn percentages.
How to Run
Install MySQL and load the Chinook database (the standard Chinook SQL script).
Open the SQL files in MySQL Workbench or the MySQL command line.
Run objective_questions.sql, then subjective_questions.sql.
Note that Subjective Q10 changes the schema by running ALTER TABLE album ADD COLUMN ReleaseYear INTEGER;. Run it on a copy if you want to keep the original schema.
