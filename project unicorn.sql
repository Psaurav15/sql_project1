
create Table Unicorns(
		STARTUP_NAME varchar(40),
		INDUSTRY varchar(40),
		FOUNDING_YEAR int,
		UNICORN_ENTRY_YEAR int,
		PROFIT_LOSS_FY22  text,
		CURRENT_VALUATION text,
		ACQUISITIONS text,
		STATUS varchar(25)
);

drop table Unicorns

select * from Unicorns



alter table Unicorns
add Column sr_no serial primary key;

CREATE TABLE unicorns_new (
    serial_no SERIAL PRIMARY KEY,
    startup_name VARCHAR(40),
    industry VARCHAR(40),
    founding_year INT,
    unicorn_entry_year INT,
    profit_loss_fy22 TEXT,
    current_valuation TEXT,
    acquisitions TEXT,
    status VARCHAR(50)
);

select * from Unicorns

INSERT INTO unicorns_new (
    startup_name,
    industry,
    founding_year,
    unicorn_entry_year,
    profit_loss_fy22,
    current_valuation,
    acquisitions,
    status
)
SELECT 
    startup_name,
    industry,
    founding_year,
    unicorn_entry_year,
    profit_loss_fy22,
    current_valuation,
    acquisitions,
    status
FROM unicorns;

ALTER TABLE unicorns_new RENAME TO unicorns

-- clearing and altering the data 
SELECT * FROM unicorns
WHERE startup_name IS NULL
   OR industry is null
   or founding_year IS NULL

--checking and removing billion/ million and other data from columns to convert it into int
SELECT * FROM unicorns
WHERE profit_loss_fy22 !~ '^-?\$?\d+(\.\d+)?\s*(Million|Billion)?$'
  AND profit_loss_fy22 IS NOT NULL;


UPDATE unicorns
SET profit_loss_fy22 = NULL
WHERE profit_loss_fy22 LIKE 'NA';

SELECT * FROM unicorns
WHERE  current_valuation!~ '^-?\$?\d+(\.\d+)?\s*(Million|Billion)?$'
  AND profit_loss_fy22 IS NOT NULL;

UPDATE unicorns
SET   current_valuation = NULL
WHERE   current_valuation LIKE 'NA';

SELECT * FROM unicorns
WHERE  acquisitions  =  'NA'

UPDATE unicorns
SET   acquisitions = '0'
WHERE   acquisitions = 'NA';

ALTER TABLE unicorns
ALTER COLUMN acquisitions TYPE INTEGER
USING acquisitions::INTEGER;

SELECT * FROM unicorns
WHERE  profit_loss_fy22  like '%Bill%'

--creating other coulums and without altering origial column

ALTER TABLE unicorns
ADD COLUMN profit_loss_usd NUMERIC,
ADD COLUMN valuation_usd NUMERIC;

UPDATE unicorns
SET profit_loss_usd = CASE
    WHEN profit_loss_fy22 ILIKE '%million%' THEN 
        REGEXP_REPLACE(profit_loss_fy22, '[^0-9\.\-]', '', 'g')::NUMERIC * 1000000
    WHEN profit_loss_fy22 ILIKE '%billion%' THEN 
        REGEXP_REPLACE(profit_loss_fy22, '[^0-9\.\-]', '', 'g')::NUMERIC * 1000000000
    ELSE NULL
END;

UPDATE unicorns
SET valuation_usd = CASE
    WHEN current_valuation ILIKE '%million%' THEN 
        REGEXP_REPLACE(current_valuation, '[^0-9\.\-]', '', 'g')::NUMERIC * 1000000
    WHEN current_valuation ILIKE '%billion%' THEN 
        REGEXP_REPLACE(current_valuation, '[^0-9\.\-]', '', 'g')::NUMERIC * 1000000000
    ELSE NULL
END;


ALTER TABLE unicorns
drop COLUMN profit_loss_fy22;

ALTER TABLE unicorns
drop COLUMN current_valuation;


SELECT * FROM unicorns
--now data seems okay. 
--tesing few questions to get reults from available data

--1 How many unicorns were born each year across industries?
select industry,  founding_year, count(*) as total_startups  from unicorns
group by  industry, founding_year
order by founding_year asc, total_startups DESC

--2 Which three industries produced the most unicorns in the past decade?

 SELECT * FROM unicorns
 SELECT MAX(founding_year) AS newest_year FROM unicorns;
 
 --thus need to find answer for 2014-2023
 select  distinct industry, count(startup_name) as count_decade from unicorns
 WHERE founding_year > '2013' 
 group by industry
 order by count_decade desc
 limit 3

 

 --3 What is the average valuation by industry and year?
 SELECT * FROM unicorns
 
 select industry, unicorn_entry_year, round(avg(valuation_usd),2) as avg_valuation from unicorns
 group by industry, unicorn_entry_year
 order by unicorn_entry_year desc


 --4 Which year saw the most unicorns created ?

 select unicorn_entry_year, count(startup_name) no_of_unicorn from unicorns
 group by unicorn_entry_year
 order by no_of_unicorn desc
 limit 1

 --5 What’s the distribution of unicorns by industry?
 
 SELECT industry, COUNT(*) AS total_unicorns FROM unicorns
GROUP BY industry
ORDER BY total_unicorns DESC;
 
 
 --in %
SELECT industry, COUNT(*) AS total_unicorns, 
ROUND(100.0 * COUNT(*)/SUM(COUNT(*))OVER(),2) AS percentage_share
FROM unicorns
GROUP BY industry
ORDER BY percentage_share DESC;


--6 what startup is 4th (nth) in  acquisition of companies
SELECT * FROM unicorns
select sum(acquisitions) as total from unicorns

select startup_name, sum(acquisitions) as total_acquisitions from unicorns
group by startup_name
order by total_acquisitions desc
offset 3 limit 1  --change offset to (n-1)

--7 Which  industry has maximum profit in latest YEAR
select industry, sum(profit_loss_usd) as total_profit from unicorns
where  unicorn_entry_year =(select max(unicorn_entry_year) from unicorns) and profit_loss_usd is not null
group by industry 
order by total_profit desc
limit 1

