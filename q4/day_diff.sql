-- SELECT date_joined, transaction_time
-- FROM bo.client AS c
-- INNER JOIN bo.payment AS p
-- ON c.loginid = p.client_loginid
-- LIMIT 10

-- SELECT date_joined
-- 	, transaction_time
-- 	, extract(day from "transaction_time" - "date_joined") AS day_diff
-- FROM bo.client AS c
-- INNER JOIN bo.payment AS p
-- ON c.loginid = p.client_loginid
-- ORDER BY day_diff ASC
-- LIMIT 10

-- -- -- -- #1 GET FIRST DEPOSIT
-- SELECT DISTINCT ON (loginid)
-- 	loginid
-- 	, (SELECT transaction_time
-- 	   FROM bo.payment
-- 	   WHERE transfer_type LIKE '%Deposit%'
-- 	   ORDER BY transaction_time ASC
-- 	   LIMIT 1) AS first_deposit
-- FROM bo.payment AS p
-- INNER JOIN bo.client AS c
-- ON p.client_loginid = c.loginid

-- -- -- -- #2 GET DATE DIFF (NO CTE)
-- SELECT DISTINCT ON (loginid)
-- 	loginid
-- 	, date_joined
-- 	, (SELECT transaction_time
-- 	   FROM bo.payment
-- 	   WHERE transfer_type LIKE '%Deposit%'
-- 	   ORDER BY transaction_time ASC
-- 	   LIMIT 1	)AS first_deposit
-- 	, transfer_type
-- 	, source
-- 	, extract(day from "transaction_time" - "date_joined") AS day_diff
-- FROM bo.client AS c
-- INNER JOIN bo.payment AS p
-- ON c.loginid = p.client_loginid
-- GROUP BY source, loginid, transfer_type, transaction_time
-- LIMIT 10

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
