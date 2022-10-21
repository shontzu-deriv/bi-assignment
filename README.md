# BI FINAL ASSIGNMENT LEZGO
<div id="toc"></div>

## TABLE OF CONTENTS
* [Q1: Identify outliers, errors and invalid values, document and explain your ETL process](#q1)
    * [#1: EXAMINE TABLES INDIVIDUALLY](#q1s1)
    * [#2: JOIN BOTH TABLES AND EXAMINE](#q1s2)
    * [#3: DUPLICATE CHECK](#q1s3)
    * [#4: FOUND DUPLICATE iso2 (Indonesia, ID)](#q1s4)
    * [#5: JOIN country AND client TABLES TO LOCATE ALL CLIENTS REGISTERED FROM Indonesia,ID](#q1s5)
    * [#6: FIND OUTLIERS](#q1s6)

* [Q2: LASHWEEN](#q2)
    * [todo](#)
    * [todo](#)
    * [todo](#)

* [Q3: DASHBOARD](#q3)
    * [todo](#)
    * [todo](#)
    * [todo](#)
    
* [Q4: YUUCHIN](#q4)
    * [todo](#)
    * [todo](#)
    * [todo](#)

<div id="q1"></div>

# Question 1 

**Identify values that are outliers, errors and invalid.
<br><br>
Eliminate or fix them and explain the logic of your data cleaning. [0.5 - 1 hour]
<br><br>
Hint: Check the affiliate table and do a duplicate check iso2 column in dict_country table and check if there are missing values for countries by joining with affiliate and client table. The output expected is a list of rows that exist in any of the tables provided and some written explanation**  <span style="font-size:small">([back to TOC](#toc))</span> 

<div id="q1s1"></div>

### #1: EXAMINE TABLES INDIVIDUALLY 
```
SELECT * FROM bo.dict_country LIMIT 5
```
<a>![Foo](https://raw.githubusercontent.com/shontzu/bi-assignment/main/assets/bo.dict_country.png)</a>

```
SELECT * FROM bo.client LIMIT 5
```
<a>![Foo](https://raw.githubusercontent.com/shontzu/bi-assignment/main/assets/bo.client.png)</a>

<span style="font-size:small">([back to TOC](#toc))</span>

<div id="q1s2"></div>

### #2: JOIN BOTH TABLES AND EXAMINE 
```
SELECT country, geography_region, iso2, c.residence FROM bo.dict_country AS dc
LEFT JOIN bo.client AS c
ON dc.iso2 = UPPER(c.residence)
LIMIT 10;
```
<a>![Foo](https://raw.githubusercontent.com/shontzu/bi-assignment/main/assets/q1_join1.png)</a>

<span style="font-size:small">([back to TOC](#toc))</span>

<div id="q1s3"></div>

### #3: DUPLICATE CHECK 
```
SELECT residence, count(residence)
FROM bo.client 
GROUP BY residence
HAVING COUNT(residence)>1
```
<a>![Foo](https://raw.githubusercontent.com/shontzu/bi-assignment/main/assets/duplicate_check1.png)</a>

```
SELECT iso2, count(iso2)
FROM bo.dict_country 
GROUP BY iso2
HAVING COUNT(iso2)>1
```
<a>![Foo](https://raw.githubusercontent.com/shontzu/bi-assignment/main/assets/duplicate_check2.png)</a>

<span style="font-size:small">([back to TOC](#toc))</span>

<div id="q1s4"></div>

### #4: FOUND DUPLICATE iso2 (Indonesia, ID) 
`SELECT * FROM bo.dict_country WHERE iso2 = 'ID' `

<a>![Foo](https://raw.githubusercontent.com/shontzu/bi-assignment/main/assets/q1.1.png)</a>

<span style="font-size:small">([back to TOC](#toc))</span>
<div id="q1s5"></div>

### #5: JOIN `country` AND `client` TABLES  
LOCATED ALL CLIENTS REGISTERED FROM `Indonesia,ID`
#### METHOD 1
```
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
```
<a>![Foo](https://raw.githubusercontent.com/shontzu/bi-assignment/main/assets/q1.2.png)</a>

#### METHOD 2
```
SELECT loginid
	, CONCAT(first_name, ' ', last_name) AS name
	, UPPER(c.residence) AS residence
	, d.iso3
FROM bo.client AS c
LEFT JOIN bo.dict_country AS d
ON UPPER(c.residence) = d.iso2
WHERE d.iso3 = 'NULL'
GROUP BY loginid, first_name, last_name, c.residence, d.iso2, d.iso3
```
<a>![Foo](https://raw.githubusercontent.com/shontzu/bi-assignment/main/assets/q1.3.png)</a>
<span style="font-size:small">([back to TOC](#toc))</span>
<div id="q1s6"></div>

### #6: FIND OUTLIERS 
#### Column name inconsistency (`bo.client.residence = bo.dict_country.iso2`)
<a>![q1.4.png](https://raw.githubusercontent.com/shontzu/bi-assignment/main/assets/q1.4.png)</a>

#### Capitalization inconsistency (RU and ru)
<a>![q1.5.png](https://raw.githubusercontent.com/shontzu/bi-assignment/main/assets/q1.5.png)</a>

<span style="font-size:small">([back to TOC](#toc))</span>



# Question 4
### CORRELATION BETWEEN NUM OF AFFILIATES AND NUM OF CLIENTS
```
with

new_affiliate as
(
	SELECT extract(YEAR from "date_joined")AS year
		, COUNT(DISTINCT affiliate_id) AS new_affiliates
		, affiliate_id
	FROM bo.affiliate
	GROUP BY year, affiliate_id
	ORDER BY year ASC
),

new_client as
(
	SELECT extract(YEAR from "date_joined")AS year
		, COUNT(DISTINCT loginid) AS new_clients
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
```
<a>![Foo](https://raw.githubusercontent.com/shontzu/bi-assignment/main/q4/affiliate_client_by_year.png)</a>

### CORRELATION BETWEEN NUMBER OF AFFILIATES AND AVERAGE CONVERSION BY COUNTRY
#### AVG CONVERSION
```
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

SELECT * FROM conversion_per_country WHERE avg_conversion<100
```
#### AFFILIATES PER COUNTRY
```
SELECT DISTINCT ON (country) 
    country
    , COUNT(*) As num_of_affiliates
    , SUM(num_of_hits) AS num_of_hits
    , SUM(num_of_clients) AS num_of_clients
    , AVG(conversion_rate) AS avg_conversion_rate
FROM conversion_rate
GROUP BY country


```
<a>![Foo](https://raw.githubusercontent.com/shontzu/bi-assignment/main/q4/affiliate_vs_client_by_country.png)</a>

### TREND OF CLIENT SIGNUP
```
 SELECT  DATE_TRUNC('month',date_joined) as signup_month
       , COUNT(loginid) AS signup_clients
   FROM bo.client
  GROUP BY 1
  ```
<a>![Foo](https://raw.githubusercontent.com/shontzu/bi-assignment/main/q4/client_signup_monthly.png)</a>

### NET PROFIT PER COUNTRY
```
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
```
<a>![Foo](https://raw.githubusercontent.com/shontzu/bi-assignment/main/q4/net_profit_by_country.png)</a>

