/*
1.	Avant partners with other websites to drive customer traffic to its application. Today, one of our affiliate partners called to tell us that they were sending us similar volume of traffic everyday but over the last couple of days we are funding significantly fewer customers than we used to before. You have been asked to investigate the cause of the issue(s). What questions would you ask and what data would you need to analyze to answer those questions?
*/
Please find below my analysis and observations:

a. I would like to check if the traffic we are getting is really unique? If same set of people visits the site everyday traffic might increase but the number of unique customers visiting the site is less. We might require the Ip adderss, location, browser stats so that
we can dig much deeper.
b. Also, If we are acquiring wrong traffic for our application this might result in less interested number of customers. We would like to
collect cookie information from their browser to see what they have recently searched for ? So, that we can evaluate what a customer searched before and is he really interested in taking a credit.
c. We might need to check if there is another service with much more compelling offer than ours. A detailed comparison could provide us with valid insights. We might come up with some new exciting offers.
d. The application customer interacts with might be too complex or time consuming procedure. We can get the mouse clicks information from our application and see how much time it is taken to submit the request once it is started.
----------------------------------------------------------------------------------------------------------------------------------
/* 
2.	Avant’s design team has come up with a new, user-friendly design of our online loan application. You have been tasked with analyzing the new design. What metrics/data would you want to track in order to evaluate the success of the redesign? 
*/


Please find below my observations:

a. Compatible with most commonly used Desktop as well as mobile browsers
b. Information entered into all data fields should have quick fill such that all default options will be intelligently filled along with 
help buttons to provide more detailed instruction.
c. The system should have proper validations and will automatically list all known issues prior to form submittal.
d. System will automatically log you out after a specified amount of inactivity.
e. We can get the mouse clicks information from our application and see how much time it is taken to submit the request once it is started. If an application is started , but not submitted we will have just start time. We can get some really good insight by tracking this information
f. Track most frequently accessed page by customers, which helps us to improve the page.
e. Have a feedback page so that we can collect customer opinions about the design.


----------------------------------------------------------------------------------------------------------------------------------
/*

SQL QUERY QUESTIONS :

1.Write an SQL query (preferably using PostgreSQL syntax, but not mandatory) that shows the id and 
first_name of all non-bankrupt applicants (bankrupt applicants can be identified when the bankruptcy_flg = ‘t’). 
For each applicant also display the total number of products associated with them (regardless of status), 
and the total volume (in dollars) of products that have been issued/funded to 
them (determined by amount_cents in the products table).

Implemented the query in two ways:

a. In order to check results for all of the Applicants who are not bankrupt and have
at least one product. Used Inner Join
Query Snapshot and Results available at https://app.wagonhq.com/snapshot/7cab6z6idcegtu5m

*/

SELECT applicants.id AS id
	,applicants.first_name AS NAME
	,COUNT(DISTINCT products.id) AS Total_Products
	,CASE 
		WHEN SUM(amount_cents) IS NULL
			THEN 0
		ELSE SUM(amount_cents)::FLOAT / 100
		END AS Total_Volume
FROM APPLICANTS
INNER JOIN PRODUCTS ON applicants.id = products.applicant_id
WHERE bankruptcy_flg <> 't'
GROUP BY 1
	,2
ORDER BY 1
	,2;
/*
b. In order to check results for all of the Applicants who are not bankrupt and have
0 or more products. Used Left Outer Join

Query Snapshot and Results available at https://app.wagonhq.com/snapshot/ely24ezeok73ias2
*/

SELECT applicants.id AS id
	,applicants.first_name AS NAME
	,COUNT(DISTINCT products.id) AS Total_Products
	,CASE 
		WHEN SUM(amount_cents) IS NULL
			THEN 0
		ELSE SUM(amount_cents)::FLOAT / 100
		END AS Total_Volume
FROM APPLICANTS
LEFT JOIN PRODUCTS ON applicants.id = products.applicant_id
WHERE bankruptcy_flg <> 't'
GROUP BY 1
	,2
ORDER BY 1
	,2;

----------------------------------------------------------------------------------------------------------------------------------
/* 
2.Modify the query above to only display applicants whose total dollars funded exceed $5000

In order to check results for all of the Applicants who are not bankrupt and have
0 or more products with total volume greater than 5000 Used Left Outer Join

Query Snapshot and Results available at https://app.wagonhq.com/snapshot/wegqoujm4wmml7bb

*/
SELECT applicants.id AS id
	,applicants.first_name AS NAME
	,COUNT(DISTINCT products.id) AS Total_Products
	,CASE 
		WHEN SUM(amount_cents) IS NULL
			THEN 0
		ELSE SUM(amount_cents)::FLOAT / 100
		END AS Total_Volume
FROM APPLICANTS
LEFT JOIN PRODUCTS ON applicants.id = products.applicant_id
WHERE bankruptcy_flg <> 't'
GROUP BY 1
	,2
HAVING CASE 
		WHEN SUM(amount_cents) IS NULL
			THEN 0
		ELSE SUM(amount_cents)::FLOAT / 100
		END > 5000
ORDER BY 1
	,2;

----------------------------------------------------------------------------------------------------------------------------------
/*
3.Modify the query above to include each applicant’s ranking (based on the number of total products –calculated in step 1). 
Additionally, show what proportion of the set’s total funded amount belongs to each applicant. 
Note that all previous conditions still apply

To calculate Rank (used dense_rank() so that we wont have any gaps in rankings alternatively we can use rank() also 
To calculate the proportion of each applicant)

Query Snapshot and Results available at https://app.wagonhq.com/snapshot/3zezep63xvdcj3gf

*/


SELECT x.id
	,x.NAME
	,x.total_products
	,x.total_volume AS total_volume
	,x.total_volume * 100::FLOAT / c.total_set_volume AS proportion
	,dense_rank() OVER (
		ORDER BY x.total_products DESC
		)
FROM (
	SELECT applicants.id AS id
		,applicants.first_name AS NAME
		,COUNT(DISTINCT products.id) AS Total_Products
		,CASE 
			WHEN SUM(amount_cents) IS NULL
				THEN 0
			ELSE SUM(amount_cents)::FLOAT / 100
			END AS Total_Volume
	FROM APPLICANTS
	LEFT JOIN PRODUCTS ON applicants.id = products.applicant_id
	WHERE bankruptcy_flg <> 't'
	GROUP BY 1
		,2
	HAVING CASE 
			WHEN SUM(amount_cents) IS NULL
				THEN 0
			ELSE SUM(amount_cents)::FLOAT / 100
			END > 5000
	) x
CROSS JOIN (
	SELECT SUM(amount_cents)::FLOAT / 100 AS total_set_volume
	FROM products
	) c;
----------------------------------------------------------------------------------------------------------------------------------
/*
4.Write an SQL query that shows the total principal collected (in dollars), interest collected (in dollars), 
by Transaction Task Eff Month (determined by Eff_date), as well as the total dollar amount 
funded that month (determined by products table – reference funding date and amount_cents)
*/

-- Query Snapshot and Results available at https://app.wagonhq.com/snapshot/c2hohn5yy7kb6ujo

SELECT CASE 
		WHEN a.total_amount IS NULL
			THEN 0
		ELSE a.total_amount
		END AS total_amount_funded
	,b.principle_amount as principle_collected
	,b.interest_amount as interest_collected
	,coalesce(a.months, b.months) AS months
	,coalesce(a.years, b.years) AS years
FROM (
	SELECT sum(amount_cents)::FLOAT / 100 AS total_amount
		,extract(month FROM funding_date) AS months
		,extract(year FROM funding_date) AS years
	FROM products
	GROUP BY months
		,years
	) a
FULL OUTER JOIN (
	SELECT sum(CASE 
				WHEN credit_account = 'principal_ar'
					THEN amount_cents
				ELSE 0
				END)::FLOAT / 100 AS principle_amount
		,sum(CASE 
				WHEN credit_account = 'interest_ar'
					THEN amount_cents
				ELSE 0
				END)::FLOAT / 100 AS interest_amount
		,extract(month FROM eff_date) AS months
		,extract(year FROM eff_date) AS years
	FROM transaction_details
	GROUP BY months
		,years
	) b ON a.years = b.years
	AND a.months = b.months
ORDER BY years
	,months

----------------------------------------------------------------------------------------------------------------------------------
/*
5.	Write an SQL query whose output is 1 date column. This column should include a list of all unique dates on which a product was either funded or came due (refer to funding_date, due_date in products).

Query and snapshot available at https://app.wagonhq.com/snapshot/cyusxf22pl5zjyof
*/

SELECT funding_date 
FROM   products 
WHERE  funding_date IS NOT NULL 
UNION 
SELECT due_date 
FROM   products 
WHERE  due_date IS NOT NULL 
ORDER  BY 1 

