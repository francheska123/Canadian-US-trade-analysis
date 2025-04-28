-- create schema --
CREATE SCHEMA `project_DA`;

-- set default database --
USE `project_DA`;

-- add new exports table --
CREATE TABLE `exports`(
`industry_code` int NOT NULL,
`year` int not NULL, 
`export_value` decimal(18,2) DEFAULT NULL,
PRIMARY KEY (`industry_code`, `year`)
);

-- add new imports table -- 
CREATE TABLE `imports`(
`industry_code` int NOT NULL,
`year` int not NULL, 
`import_value` decimal(18,2) DEFAULT NULL,
PRIMARY KEY (`industry_code`, `year`)
);

-- add new industry_key table --
CREATE TABLE `industry`(
`industry_code` int NOT NULL, 
`industry_name` text,
PRIMARY KEY (`industry_code`)
);

CREATE TABLE `canada_gdp`(
`year` int NOT NULL, 
`GDP` BIGINT NOT NULL, 
PRIMARY KEY (`year`)
);

select * from imports;

--     Which industries had the highest trade surpluses with the U.S. from 2002-2024?  -- 
SELECT 
e.industry_code,
ind.industry_name,
e.year, 
e.export_value as exports, 
i.import_value as imports,
(e.export_value - i.import_value) AS trade_balance
FROM exports AS e
LEFT JOIN imports as i
	on e.industry_code = i.industry_code
	and e.year = i.year
LEFT JOIN industry as ind
	on e.industry_code = ind.industry_code
    and i.industry_code = ind.industry_code
ORDER by trade_balance DESC;

-- checking industry code/name --
SELECT 
    COALESCE(e.industry_code, i.industry_code, ind.industry_code) AS industry_code,
    ind.industry_name,
    COALESCE(e.year, i.year) AS year,
    e.export_value AS exports, 
    i.import_value AS imports,
    (COALESCE(e.export_value, 0) - COALESCE(i.import_value, 0)) AS trade_balance
FROM exports AS e
LEFT JOIN imports AS i 
    ON e.industry_code = i.industry_code 
    AND e.year = i.year
LEFT JOIN industry AS ind 
    ON e.industry_code = ind.industry_code

UNION

SELECT 
    COALESCE(e.industry_code, i.industry_code, ind.industry_code) AS industry_code,
    ind.industry_name,
    COALESCE(e.year, i.year) AS year,
    e.export_value AS exports, 
    i.import_value AS imports,
    (COALESCE(e.export_value, 0) - COALESCE(i.import_value, 0)) AS trade_balance
FROM imports AS i
LEFT JOIN exports AS e 
    ON e.industry_code = i.industry_code 
    AND e.year = i.year
LEFT JOIN industry AS ind 
    ON i.industry_code = ind.industry_code;
    
 -- checking if canada imports anything it doesn't export --   
SELECT 
e.industry_code,
e.year, 
e.export_value as exports, 
i.import_value as imports,
(e.export_value - i.import_value) AS trade_balance
FROM exports AS e
LEFT JOIN imports as i
	on e.industry_code = i.industry_code
	and e.year = i.year
ORDER by trade_balance DESC;

-- checking if the above is fine --
SELECT 
i.industry_code,
i.year, 
i.import_value as imports, 
e.export_value as exports,
(e.export_value - i.import_value) AS trade_balance
FROM imports AS i
LEFT JOIN exports as e
	on i.industry_code = e.industry_code
	and i.year = e.year
ORDER by trade_balance DESC;

-- Which are the top 3 industries with the highest trade surpluses between Canada and the U.S. for each respective year of the past 5 years?  -- 

SELECT 
e.industry_code,
ind.industry_name,
e.year, 
e.export_value as exports, 
i.import_value as imports,
(e.export_value - i.import_value) AS trade_balance
FROM exports AS e
LEFT JOIN imports as i
	on e.industry_code = i.industry_code
	and e.year = i.year
LEFT JOIN industry AS ind 
    ON e.industry_code = ind.industry_code
GROUP by year 2022
ORDER by trade_balance DESC;

-- 
SELECT 
    e.industry_code,
    ind.industry_name,
    e.year, 
    SUM(e.export_value) AS exports, 
    SUM(i.import_value) AS imports,
    (SUM(e.export_value) - SUM(i.import_value)) AS trade_balance
FROM exports AS e
LEFT JOIN imports AS i
    ON e.industry_code = i.industry_code
    AND e.year = i.year
LEFT JOIN industry AS ind 
    ON e.industry_code = ind.industry_code
WHERE e.year = 2024 
GROUP BY e.industry_code, ind.industry_name, e.year
ORDER BY trade_balance DESC
LIMIT 4;

SELECT 
    i.industry_code,
    ind.industry_name,
    i.year, 
    SUM(e.export_value) AS exports, 
    SUM(i.import_value) AS imports,
    (COALESCE(SUM(e.export_value), 0) - COALESCE(SUM(i.import_value), 0)) AS trade_balance
FROM imports AS i
LEFT JOIN exports AS e
    ON i.industry_code = e.industry_code
    AND i.year = e.year
LEFT JOIN industry AS ind 
    ON i.industry_code = ind.industry_code
WHERE i.year = 2024 
GROUP BY i.industry_code, ind.industry_name, i.year
ORDER BY trade_balance DESC
LIMIT 4;

Create table industry_years AS  -- This table builds a list of unique industry-year pairs first.
Select distinct industry_code, year from exports
Union
Select distinct industry_code, year from imports;
-- 1. Calculate the trade balance for all industries and years
Create table all_trade_balances as
Select
	iy.industry_code,
    ind.industry_name,
    iy.year,
    e.export_value as exports,
    i.import_value as imports,
    coalesce(e.export_value, 0) - coalesce(i.import_value, 0) as trade_balance
From industry_years as iy
Left join exports as e
	on iy.industry_code = e.industry_code
	and iy.year = e.year
Left join imports as i
	on iy.industry_code = i.industry_code
    and iy.year = i.year
Left join industry as ind
	on iy.industry_code = ind.industry_code;
Select * from all_trade_balances;

-- For each year (2020-2024) find the top 3 industries with the highest trade surpluses --

Select industry_code, industry_name, year, exports, imports, trade_balance
From all_trade_balances
Where year = 2020
Order by trade_balance desc
Limit 4;
Select industry_code, industry_name, year, exports, imports, trade_balance
From all_trade_balances
Where year = 2021
Order by trade_balance desc
Limit 4;
Select industry_code, industry_name, year, exports, imports, trade_balance
From all_trade_balances
Where year = 2022
Order by trade_balance desc
Limit 4;
Select industry_code, industry_name, year, exports, imports, trade_balance
From all_trade_balances
Where year = 2023
Order by trade_balance desc
Limit 4;
Select industry_code, industry_name, year, exports, imports, trade_balance
From all_trade_balances
Where year = 2024
Order by trade_balance desc;
-- For each year (2020-2024) find the top 3 industries with the highest trade deficits
Select industry_code, industry_name, year, exports, imports, trade_balance
From all_trade_balances
Where year = 2020
Order by trade_balance asc
Limit 4;
Select industry_code, industry_name, year, exports, imports, trade_balance
From all_trade_balances
Where year = 2021
Order by trade_balance asc
Limit 4;
Select industry_code, industry_name, year, exports, imports, trade_balance
From all_trade_balances
Where year = 2022
Order by trade_balance asc
Limit 4;
Select industry_code, industry_name, year, exports, imports, trade_balance
From all_trade_balances
Where year = 2023
Order by trade_balance asc
Limit 4;
Select industry_code, industry_name, year, exports, imports, trade_balance
From all_trade_balances
Where year = 2024
Order by trade_balance asc
Limit 4;

-- 2018-2019 Tariffs Effects --
-- Steel, specifically looking at trade balance during 2018-2019 --
SELECT 
    *
FROM 
    all_trade_balances
WHERE
    industry_code = 33111
    AND (year = 2018 OR year = 2019);
    
-- Steel, all years --
SELECT 
    *
FROM 
    all_trade_balances
WHERE
    industry_code = 33111;
    
-- Alumina and aluminum production and processing, all years -- 
SELECT 
    *
FROM 
    all_trade_balances
WHERE
    industry_code = 33131;
    
-- Alumina and aluminum production and processing, between 2008-2019 -- 
SELECT 
    *
FROM 
    all_trade_balances
WHERE
    industry_code = 33131
    AND year BETWEEN 2008 AND 2019;

-- Non-ferrous metal (except aluminum) smelting and refining, all years --
SELECT 
    *
FROM 
    all_trade_balances
WHERE
    industry_code = 33141;

-- All trade balance --
SELECT *
FROM all_trade_balances;

-- What percentage of Canada's GDP is accounted for by trade (total imports + exports)? --

-- created table to identify the sum of exports and the sum of imports per year so getting the total --
Create table trade_summary_per_year as
Select
    year,
    SUM(exports) as sum_exports,
    SUM(imports) as sum_imports,
    SUM(exports - imports) as trade_balance
From all_trade_balances
GROUP BY year
ORDER BY year;

SELECT * FROM trade_summary_per_year;

-- making an inner join to get the trade percentage of GDP --

SELECT
t.year, 
t.sum_exports as exports, 
t.sum_imports as imports,
g.GDP,
((t.sum_exports + t.sum_imports) / g.GDP) * 100 *1000000 AS trade_percentage_of_GDP
FROM trade_summary_per_year as t
JOIN canada_gdp AS g
	on t.year = g.year
ORDER BY t.year ASC;

-- Steel, all years --
SELECT
    *
FROM
    all_trade_balances
WHERE
    industry_code = 33111
    AND year BETWEEN 2007 AND 2024
    order by year asc;
    
-- Aluminum, all years --
SELECT
    *
FROM
    all_trade_balances
WHERE
    industry_code = 33131
    AND year BETWEEN 2007 AND 2024
    order by year asc;
    
-- corrected trade percentage --
SELECT
    t.year, 
    t.sum_exports AS exports, 
    t.sum_imports AS imports,
    g.GDP,
    ((t.sum_exports * 1e6 + t.sum_imports * 1e6) / g.GDP) * 100 AS trade_percentage_of_GDP
FROM trade_summary_per_year AS t
JOIN canada_gdp AS g
    ON t.year = g.year
ORDER BY t.year ASC;

SELECT 
	industry_name
FROM all_trade_balances;
-- average percentage across all years for oil and gas vs other industries --
SELECT
    AVG(oil_gas_trade_percentage) AS avg_oil_gas_trade_percentage
FROM (
    SELECT
        year,
        SUM(CASE WHEN industry_name = 'Oil and gas extraction (except oil sands)' THEN exports + imports ELSE 0 END) AS oil_gas_trade,
        SUM(exports + imports) AS total_trade,
        (SUM(CASE WHEN industry_name = 'Oil and gas extraction (except oil sands)' THEN exports + imports ELSE 0 END) / SUM(exports + imports)) * 100 AS oil_gas_trade_percentage
    FROM all_trade_balances
    GROUP BY year
) yearly_data;

        
SELECT * 
FROM all_trade_balances
WHERE industry_name = 'Oil and gas extraction (except oil sands)';

-- oil and gas percentage general average during the period -- 
SELECT
    -- Calculate the oil/gas contribution to overall trade balance
    (SELECT AVG(trade_balance)
     FROM all_trade_balances
     WHERE industry_name LIKE 'Oil and gas extraction (except oil sands)'
     AND year BETWEEN 2002 AND 2024) AS avg_oil_gas_trade_balance,
    -- Calculate the total trade balance across all industries
    (SELECT AVG(total_balance) FROM
        (SELECT
            year,
            SUM(trade_balance) AS total_balance
         FROM all_trade_balances
         WHERE year BETWEEN 2002 AND 2024
         GROUP BY year) AS yearly_totals
    ) AS avg_total_trade_balance,
    -- Calculate the percentage contribution
    (SELECT AVG(trade_balance)
     FROM all_trade_balances
     WHERE industry_name LIKE 'Oil and gas extraction (except oil sands)'
     AND year BETWEEN 2002 AND 2024) /
    (SELECT AVG(total_balance) FROM
        (SELECT
            year,
            SUM(trade_balance) AS total_balance
         FROM all_trade_balances
         WHERE year BETWEEN 2002 AND 2024
         GROUP BY year) AS yearly_totals
    ) * 100 AS percentage_contribution

