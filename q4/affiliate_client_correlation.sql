with
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