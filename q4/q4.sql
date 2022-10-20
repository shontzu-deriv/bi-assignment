-- -- ACCEPTED VS DENIED AFFILIATE
SELECT COUNT(*) FROM bo.affiliate WHERE status = 'denied' LIMIT 5 -- 5 denied
SELECT COUNT(*) FROM bo.affiliate WHERE status = 'accepted' LIMIT 5 -- 95 accepted


-- -- WHERE ARE THE DENIED AFFILIATES FROM 
SELECT country, COUNT(*)
FROM bo.affiliate 
WHERE status = 'denied'
GROUP BY country
-- -- the 5 denied accounts are all from andorra, ad


-- -- TOP 5 COUNTRIES BY AFFILIATE COUNT
SELECT country, COUNT(*)
FROM bo.affiliate 
WHERE status = 'accepted'
GROUP BY country
ORDER BY count DESC
LIMIT 5
-- -- top 5 countries are br, bf, id, ng, and vn

-- -- TOP 5 COUNTRIES BY AFFILIATE WITH LEADING CLIENTS

-- -- TOP 5 COUNTRIES BY AFFILIATE WITH LEADING TOTAL DEPOSIT FROM CLIENTS


-- PSEUDOCODE
-- 3-6 PAGE BUSINESS REPORT
-- -- SURVIVAL RATE (HOW LONG THEY STAYED ON PLATFORM) 
-- -- -- SURVIVAL RATE OF AFFILIATE
-- -- -- SURVIVAL RATE OF CLIENT
-- -- -- COUNT OF CLIENTS SURVIVAL RATE GROUP BY AFFILIATE // DO A TOP-5?
-- -- -- COUNT OF CLIENTS SURVIVAL RATE GROUP BY COUNTRY // DO A TOP-5?

-- -- CONVERSION RATE (SIGNUP-TO-DEPOSIT RATE)
SELECT date_joined, transaction_time
FROM bo.client AS c
INNER JOIN bo.payment AS p
ON c.loginid = p.client_loginid
LIMIT 10

SELECT date_joined
	, transaction_time
	, extract(day from "transaction_time" - "date_joined") AS day_diff
FROM bo.client AS c
INNER JOIN bo.payment AS p
ON c.loginid = p.client_loginid
ORDER BY day_diff ASC
LIMIT 10

-- -- -- #1 GET FIRST DEPOSIT
SELECT DISTINCT ON (loginid)
	loginid
	, (SELECT transaction_time
	   FROM bo.payment
	   WHERE transfer_type LIKE '%Deposit%'
	   ORDER BY transaction_time ASC
	   LIMIT 1) AS first_deposit
FROM bo.payment AS p
INNER JOIN bo.client AS c
ON p.client_loginid = c.loginid

-- -- -- #2 GET DATE DIFF (NO CTE)
SELECT DISTINCT ON (loginid)
	loginid
	, date_joined
	, (SELECT transaction_time
	   FROM bo.payment
	   WHERE transfer_type LIKE '%Deposit%'
	   ORDER BY transaction_time ASC
	   LIMIT 1	)AS first_deposit
	, transfer_type
	, source
	, extract(day from "transaction_time" - "date_joined") AS day_diff
FROM bo.client AS c
INNER JOIN bo.payment AS p
ON c.loginid = p.client_loginid
GROUP BY source, loginid, transfer_type, transaction_time
LIMIT 10

-- -- -- USING CTE
;with first_deposit(first_deposit) as  
(
SELECT transaction_time, client_loginid
FROM bo.payment
WHERE transfer_type LIKE '%Deposit%'
ORDER BY transaction_time ASC
-- LIMIT 1
)

SELECT DISTINCT ON (loginid)
	loginid
	, date_joined
	, f.first_deposit
	, transfer_type
	, source
	, EXTRACT(day FROM "transaction_time" - "date_joined") AS day_diff
FROM bo.client AS c
INNER JOIN bo.payment AS p
ON c.loginid = p.client_loginid
INNER JOIN first_deposit AS f
ON c.loginid = f.client_loginid
-- WHERE NOT source=15284 AND NOT source=1 AND NOT source=16929 -- checking
GROUP BY source, loginid, transfer_type, transaction_time, first_deposit
LIMIT 10

-- WHERE  loginid='CR2296232' --checking
-- WHERE  loginid='CR2293774' --checking
-- WHERE loginid='CR2290964' --checking


-- -- CLIENT/AFFILIATE CLASSIFICATION (AGE GROUP, RISK GROUP)
-- -- --

-- -- TOTAL CLIENT SIGNUP MONTHLY
-- -- AVG TOTAL DEPOSIT
-- -- 
-- -- TOTAL DEPOSITS MONTHLY
-- -- TOTAL DEPOSITS QUARTERLY

-- -- -- CORRELATION BETWEEN AFFILIATE AND CLIENT ANNUALLY
new_affiliate as
(
	SELECT extract(YEAR from "date_joined")AS year
		, COUNT(affiliate_id) AS new_affiliates
		, affiliate_id
	FROM bo.affiliate
	GROUP BY year, affiliate_id
	ORDER BY year ASC
),

new_client as
(
	SELECT extract(YEAR from "date_joined")AS year
		, COUNT(loginid) AS new_clients
		, affiliate_id
	FROM bo.client
	GROUP BY year, affiliate_id
	ORDER BY year
)

SELECT a.year, SUM(new_affiliates) AS new_affiliates, SUM(new_clients) AS new_clients FROM new_affiliate as a
LEFT JOIN new_client as c
ON a.affiliate_id = c.affiliate_id
GROUP BY 1
ORDER BY 1