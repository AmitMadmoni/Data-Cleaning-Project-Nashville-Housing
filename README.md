Data Cleaning Project in PostgreSQL

-- Running instructions below

This dataset contains data regarding housing in Nashville.

The columns in this dataset are:

1. Unique ID - A unique identifier for each property record.
2. Parcel ID - A unique code assigned to a parcel of land in Nashville.
3. Land Use - The designated purpose for the property (e.g., residential, commercial).
4. Property Address - The physical address of the property.
5. Sale Date - The date when the property was sold.
6. Sale Price - The price for which the property was sold.
7. Legal Reference - A reference number for the legal documents related to the property sale.
8. Sold As Vacant - Indicates whether the property was sold as vacant land (yes or no).
9. Owner Name - The name of the current property owner.
10. Owner Address - The mailing address of the property owner.
11. Acreage - The size of the property in acres.
12. Tax District - The tax jurisdiction where the property is located.
13. Land Value - The assessed value of the land.
14. Building Value - The assessed value of buildings on the property.
15. Total Value - The total assessed value of the property (land + building).
16. Year Built - The year the property was constructed.
17. Bedrooms - The number of bedrooms in the property.
18. Full Bath - The number of full bathrooms in the property.
19. Half Bath - The number of half bathrooms in the property.

In this project, I performed data cleaning on the Nashville housing dataset using PostgreSQL, which was done in four stages:
1. Standardizing data formats and correcting errors.
2. Populating null values through JOINs.
3. Checking for duplicates using Window Functions and CTEs.
4. Deleting unnecessary columns.

Attached are the project file and the csv file contains the dataset.

Running instructions:

Download both csv file and SQL file to a specific folder in your computer.
Run the CREATE TABLE query which creates the 'nashville_housing_data' table.
Run the COPY query in order to import the data from the csv file into the table. Make sure to write the correct file location in the FROM clause.
