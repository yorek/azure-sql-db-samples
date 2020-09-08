/*
    Use WideWorldImporters Database
*/

-- Default on-prem
SELECT * FROM [Application].[Cities] WITH (READCOMMITTEDLOCK)
WHERE CityName IN ('Kirkland', 'Redmond', 'Bellevue')

-- Default in Azure
SELECT * FROM [Application].[Cities] 
WHERE CityName IN ('Kirkland', 'Redmond', 'Bellevue')

SELECT @@TRANCOUNT
