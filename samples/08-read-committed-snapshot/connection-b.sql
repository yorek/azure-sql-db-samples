/*
    Use WideWorldImporters Database
*/

-- Default in Azure
SELECT * FROM [Application].[Cities] 
WHERE CityName IN ('Kirkland', 'Redmond', 'Bellevue')

-- Uncomment the following lines to force Azure SQL to use locks to preserve consistency and isolate transactions. 
-- SELECT * FROM [Application].[Cities] WITH (READCOMMITTEDLOCK)
-- WHERE CityName IN ('Kirkland', 'Redmond', 'Bellevue')

SELECT @@TRANCOUNT
