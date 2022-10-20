with conversion(affiliate_id) as  
(
	SELECT affiliate_id
	, COUNT(loginid) AS num_of_clients
	FROM bo.client 
	GROUP BY affiliate_id
),

hit(affiliate_id) as  
(
	SELECT affiliate_id
	, COUNT(date_hit) AS num_of_hits
	FROM bo.affiliate_hit 
	GROUP BY affiliate_id
),

country(affiliate_id) as
(
	SELECT affiliate_id, country
	FROM bo.affiliate 
),

conversion_rate(affiliate_id) as
(
	SELECT conversion.affiliate_id
		, country
		, hit.num_of_hits
		, conversion.num_of_clients
		, (100.0 * CAST(conversion.num_of_clients AS int)/CAST(hit.num_of_hits AS int)) AS conversion_rate
		FROM conversion 
	LEFT JOIN hit
	ON conversion.affiliate_id = hit.affiliate_id
	LEFT JOIN country
	ON conversion.affiliate_id = country.affiliate_id
	GROUP BY conversion.affiliate_id, conversion.num_of_clients, hit.num_of_hits, country
),

affiliate_per_country(country) as
(
	SELECT DISTINCT ON (country) 
	country, COUNT(*) As num_of_affiliates
	FROM conversion_rate
	GROUP BY country
),

conversion_per_country(country) as
(
	SELECT DISTINCT ON (country) 
	country, AVG(conversion_rate) As avg_conversion
	FROM conversion_rate
	GROUP BY country
)

SELECT c.country, num_of_affiliates, avg_conversion FROM conversion_per_country AS c 
LEFT JOIN affiliate_per_country AS a
ON c.country = a.country
