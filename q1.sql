-- Identify values that are outliers, errors and invalid. 
-- Eliminate or fix them and explain the logic of your data cleaning. [0.5 - 1 hour]
--Hint: Check the affiliate table and do a duplicate check iso2 column in dict_country table and check if there are missing values for countries by joining with affiliate and client table. The output expected is a list of rows that exist in any of the tables provided and some written explanation

-- -- STEP 1: EXAMINE TABLE
SELECT * FROM bo.dict_country LIMIT 5;
bo.dict_country
country, geography_region, iso2, iso3

SELECT * FROM bo.client WHERE residence='af' LIMIT 5;
bo.client
loginid, first_name, last_name, email, residence, date_joined, date_of_birth, source, currency_code, affiliate_id


-- -- STEP 2: JOIN BOTH TABLES
SELECT country, geography_region, iso2, c.residence FROM bo.dict_country AS dc
LEFT JOIN bo.client AS c
ON dc.iso2 = UPPER(c.residence)
LIMIT 10;


-- -- STEP 3: DUPLICATE CHECK
SELECT residence, count(residence)
FROM bo.client 
GROUP BY residence
HAVING COUNT(residence)>1

SELECT iso2, count(iso2)
FROM bo.dict_country 
GROUP BY iso2
HAVING COUNT(iso2)>1

-- -- FOUND DUPLICATE iso2 (Indonesia, ID)
-- -- q1.1.pnq
SELECT * FROM bo.dict_country WHERE iso2 = 'ID' 


-- -- JOIN country and client table to locate all clients registered in Indonesia,ID
-- -- METHOD 1
SELECT loginid
	, CONCAT(first_name, ' ', last_name) AS name
	, UPPER(c.residence) AS residence
	, d.iso2 AS iso2
	, COUNT(c.residence) AS residence_count
	, COUNT(d.iso2) AS iso2_count
FROM bo.client AS c
LEFT JOIN bo.dict_country AS d
ON UPPER(c.residence) = d.iso2
GROUP BY loginid, first_name, last_name, c.residence, d.iso2
HAVING COUNT(iso2)>1
-- -- q1.2.png

-- -- METHOD 2
SELECT loginid
	, CONCAT(first_name, ' ', last_name) AS name
	, UPPER(c.residence) AS residence
	, d.iso3
FROM bo.client AS c
LEFT JOIN bo.dict_country AS d
ON UPPER(c.residence) = d.iso2
WHERE d.iso3 = 'NULL'
GROUP BY loginid, first_name, last_name, c.residence, d.iso2, d.iso3
-- -- q1.3.png