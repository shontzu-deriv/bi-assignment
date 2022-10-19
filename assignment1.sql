-- -- what's in each table
-- SELECT * FROM agg.transaction_summary
-- LIMIT 20

-- SELECT * FROM agg.client
-- LIMIT 20

-- SELECT * FROM agg.payment
-- LIMIT 20




-- -- total number of account signups (1386)
-- SELECT COUNT(loginid) FROM agg.client




-- -- total number of user signups (612)
-- SELECT COUNT(binary_user_id) FROM 
-- 	(SELECT DISTINCT binary_user_id FROM agg.client) AS temp




-- -- total number of user signups per country 
-- SELECT 
-- 	residence, 
-- 	COUNT(binary_user_id) FROM (SELECT binary_user_id, residence FROM agg.client) AS temp
-- GROUP BY residence
-- ORDER BY residence ASC




-- -- total number of user signups per gender (m:695, f:691)
-- SELECT 
-- 	gender, 
-- 	COUNT(binary_user_id) FROM (SELECT DISTINCT binary_user_id, gender FROM agg.client) AS temp
-- GROUP BY gender




-- -- replace m and f from previous question twith male and female
-- SELECT 
-- 	CASE
--       WHEN (gender='m')  THEN 'male'
--       WHEN (gender='f')  THEN 'female'
-- 	END AS gender,
	
-- 	COUNT(binary_user_id) FROM (SELECT DISTINCT binary_user_id, gender FROM agg.client) AS temp
-- GROUP BY gender




-- -- Top countries with more users using BTC as currency_code in DESC order + number of users in each country




-- -- for each uesr, concat their list of binary_user_id and loginid and sort in DESC order
-- SELECT string_agg(loginid, ', ') AS loginid
-- 	, string_agg(CAST(binary_user_id AS VARCHAR), ', ') AS binary_user_id
-- 	, COUNT (binary_user_id) AS count
-- FROM agg.client
-- GROUP BY binary_user_id
-- ORDER BY count DESC







-- -- JOIN ALL QUERIES
SElECT c.residence
	,  string_agg(DISTINCT c.currency_code, ', ') 
	, COUNT(c.binary_user_id) AS users_count
	, COUNT(c.loginid) AS active_users_count --todo
	, (SELECT AVG(p.amount) AS avg_deposit FROM agg.payment AS p WHERE p.category LIKE '%Deposit%') --todo
	, (SELECT AVG(p.amount) AS avg_withdraw FROM agg.payment AS p WHERE p.category LIKE '%Withdraw%') --todo
FROM agg.client AS c
	LEFT JOIN agg.transaction_summary AS t
	ON c.binary_user_id = t.binary_user_id
		LEFT JOIN agg.payment AS p
		ON t.binary_user_id = p.binary_user_id
GROUP BY c.residence
ORDER BY c.residence
LIMIT 10

-- WITHDRAW
-- SELECT c.residence, p.category, AVG(p.amount) AS avg_withdraw
-- FROM agg.payment AS p 
-- 	LEFT JOIN agg.client AS c
-- 	ON p.binary_user_id = c.binary_user_id
-- WHERE p.category LIKE '%Withdraw%' 
-- GROUP BY c.residence, p.category 
-- LIMIT 10

-- -- DEPOSIT
-- SELECT c.residence, p.category, AVG(p.amount) AS avg_deposit
-- FROM agg.payment AS p 
-- 	LEFT JOIN agg.client AS c
-- 	ON p.binary_user_id = c.binary_user_id
-- WHERE p.category LIKE '%Deposit%' 
-- GROUP BY c.residence, p.category 
-- LIMIT 10
