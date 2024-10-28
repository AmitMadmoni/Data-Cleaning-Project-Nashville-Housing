CREATE TABLE IF NOT EXISTS public.nashville_housing_data
(
    unique_id integer NOT NULL,
    parcel_id text,
    land_use text,
    property_address text,
    sale_date date,
    sale_price text,
    legal_reference text,
    sold_as_vacant text,
    owner_name text,
    owner_address text,
    acreage double precision,
    tax_district text,
    land_value integer,
    building_value integer,
    total_value integer,
    year_built integer,
    bedrooms integer,
    full_bath integer,
    half_bath integer,
    CONSTRAINT nashville_housing_data_pkey PRIMARY KEY (unique_id)
)

COPY nashville_housing_data(unique_id, parcel_id, land_use, property_address, sale_date, sale_price, legal_reference,
								sold_as_vacant, owner_name, owner_address, acreage, tax_district, land_value, building_value,
								total_value, year_built, bedrooms, full_bath, half_bath)
FROM 'D:\Data Analyst\PostgreSQL Data Cleaning Project - Nashville Housing\Nashville Housing Data.csv'
DELIMITER ','
CSV HEADER;

SELECT *
FROM nashville_housing_data
ORDER BY unique_id;

-- First, we would like to create a copy of the table.
CREATE TABLE nashville_housing_data_copy
(LIKE nashville_housing_data);

INSERT INTO nashville_housing_data_copy
SELECT *
FROM nashville_housing_data;

SELECT *
FROM nashville_housing_data_copy
ORDER BY unique_id;

-- We can see there are 56477 records in this table.
SELECT COUNT(*)
FROM nashville_housing_data_copy;

-------------------------------------------------------------------------------------------------------------------------------

-- 1. Standardize data and fix errors.


-- Parcel IDs

-- Searching for abnormal lengths of parcel ids.
SELECT DISTINCT LENGTH(parcel_id)
FROM nashville_housing_data_copy;

-- Searching for parcel ids which don't contain '.'
SELECT COUNT(parcel_id)
FROM nashville_housing_data_copy
WHERE parcel_id NOT LIKE '%.%';


-- Land uses

-- Looking at the differenct land uses
SELECT DISTINCT land_use
FROM nashville_housing_data_copy
ORDER BY land_use;

-- We can notice there are different spellings and typos for 'VACANT RESIDENTIAL LAND'
SELECT DISTINCT land_use
FROM nashville_housing_data_copy
WHERE land_use LIKE 'VACANT RES%'
ORDER BY land_use;

UPDATE nashville_housing_data_copy
SET land_use = 'VACANT RESIDENTIAL LAND'
WHERE land_use LIKE 'VACANT RES%';


-- Sales prices

-- We notice there are several sales prices that contains a comma and a $ sign, which we would like to fix.
SELECT sale_price
FROM nashville_housing_data_copy
WHERE sale_price LIKE '%,%' OR sale_price LIKE '%$%'
ORDER BY sale_price;

-- We will update these records
UPDATE nashville_housing_data_copy
SET sale_price = REPLACE(REPLACE(sale_price, ',', ''), '$', '')
WHERE sale_price LIKE '%,%' OR sale_price LIKE '%$%';

-- Change sale_price type to integer
ALTER TABLE nashville_housing_data_copy
ALTER COLUMN sale_price TYPE integer USING sale_price::integer;


-- Sold as vacant

-- There are 451 values that are written Y or N instead of Yes or No
SELECT COUNT(sold_as_vacant)
FROM nashville_housing_data_copy
WHERE sold_as_vacant = 'Y' OR sold_as_vacant = 'N';

UPDATE nashville_housing_data_copy
SET sold_as_vacant = 
	CASE
		WHEN sold_as_vacant = 'Y' THEN 'Yes'
		WHEN sold_as_vacant = 'N' THEN 'No'
		ELSE sold_as_vacant
	END;


-- Breaking property address to address and city.

-- First, we will add two columns to the data table.

ALTER TABLE nashville_housing_data_copy
ADD property_street text,
ADD	property_city text;

UPDATE nashville_housing_data_copy
SET property_street = split_part(property_address, ',', 1),
	property_city = split_part(property_address, ',', 2);

SELECT property_address, property_street, property_city
FROM nashville_housing_data_copy;


-- Breaking owner address to address, city and country.

-- First, we will add three columns to the data table.

ALTER TABLE nashville_housing_data_copy
ADD owner_street text,
ADD	owner_city text,
ADD owner_country text;

UPDATE nashville_housing_data_copy
SET owner_street = split_part(owner_address, ',', 1),
	owner_city = split_part(owner_address, ',', 2),
	owner_country = split_part(owner_address, ',', 3);

SELECT owner_address, owner_street, owner_city, owner_country
FROM nashville_housing_data_copy;

-------------------------------------------------------------------------------------------------------------------------------

-- 2. populate null values.


-- Property address: there are 35 null values which we can populate.
SELECT n1.property_address, n2.property_address
FROM nashville_housing_data_copy n1 JOIN nashville_housing_data_copy n2
ON n1.parcel_id = n2.parcel_id AND n1.unique_id != n2.unique_id
WHERE n2.property_address IS NULL
ORDER BY n1.parcel_id;


UPDATE nashville_housing_data_copy n2
SET property_address = n1.property_address
FROM nashville_housing_data_copy n1
WHERE n1.parcel_id = n2.parcel_id 
  AND n1.unique_id != n2.unique_id
  AND n2.property_address IS NULL;


-- We can see there are no null addresses left
SELECT property_address
FROM nashville_housing_data_copy
WHERE property_address IS NULL;


-- Tax district: there are 20 null values which we can populate.
SELECT n1.property_address, n1.tax_district, n2.property_address, n2.tax_district
FROM nashville_housing_data_copy n1 JOIN nashville_housing_data_copy n2
ON n1.property_address = n2.property_address AND n1.unique_id != n2.unique_id
WHERE n2.tax_district IS NULL and n1.tax_district IS NOT NULL;


UPDATE nashville_housing_data_copy n2
SET tax_district = n1.tax_district
FROM nashville_housing_data_copy n1
WHERE n1.property_address = n2.property_address AND n1.unique_id != n2.unique_id
	AND n2.tax_district IS NULL AND n1.tax_district IS NOT NULL;


-------------------------------------------------------------------------------------------------------------------------------

-- 3. Remove any duplicates exists.

-- Check for duplicates

WITH row_number_cte AS
(
	SELECT *, ROW_NUMBER() OVER(PARTITION BY unique_id, parcel_id, land_use, property_address, sale_date, 
								sale_price, legal_reference, sold_as_vacant, owner_name, owner_address, 
								acreage, tax_district, land_value, building_value, total_value, year_built, 
								bedrooms, full_bath, half_bath) row_number_column
	FROM nashville_housing_data_copy
)
SELECT *
FROM row_number_cte
WHERE row_number_column > 1;

-- We can see there are no duplicates.

-------------------------------------------------------------------------------------------------------------------------------

-- 4. Remove any columns that are not necessary.

ALTER TABLE nashville_housing_data_copy
DROP property_address,
DROP owner_address;
