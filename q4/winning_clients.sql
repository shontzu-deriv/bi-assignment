with
net as (
	SELECT client_loginid
		, COALESCE(SUM(amount_usd) FILTER(WHERE amount_usd>0),0) AS deposit
		, COALESCE(SUM(amount_usd) FILTER(WHERE amount_usd<0),0) AS withdrawal
		, COALESCE(SUM(amount_usd),0) AS net
	FROM bo.payment GROUP BY client_loginid
	ORDER BY net 
),

country as (
	SELECT loginid, residence FROM bo.client
)

SELECT DISTINCT ON(residence) 
	client_loginid
	, residence 
	, deposit
	, withdrawal
	, net
	FROM net
LEFT JOIN bo.client AS c
ON net.client_loginid = c.loginid

-- PSEUDOCODE:
-- SUM Withdraw of each client
-- SUM Deposit of each client
-- SUM Deposit-Withdraw SORT ASC