-- Identify values that are outliers, errors and invalid. 
-- Eliminate or fix them and explain the logic of your data cleaning. [0.5 - 1 hour]
--Hint: Check the affiliate table and do a duplicate check iso2 column in dict_country table and check if there are missing values for countries by joining with affiliate and client table. The output expected is a list of rows that exist in any of the tables provided and some written explanation


-- Get the list of affiliates and create an affiliate profile data model (which is the base table that shows the affiliate dimension such as affiliate join date, and some metrics like how many hits they generated, first hit date, number of client signups, last hit / signup / deposit date, total deposits in USD, etc..), for the affiliate country column, display the actual Country name instead of the iso2 country code. This model will be used for analytics, so factors such as granularity, dimension and metrics of the table must be considered. [1.0-1.5 hour] Using PostgreSQL or Metabase, the output should be one single table, that one can find out the affiliate details and actions in one flat table. Record your SQL codes in snippets on how did you arrive the data model. 
--Alternatively, we can also data model using this method (link). This is not covered in our lectures, andl require you to activate the 30days trial version of Bigquery, then upload the 8 tables we have in bo schema


