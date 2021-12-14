/*
    Use WideWorldImporters Database
*/

-- Uncomment the following lines to force Azure SQL to use locks to preserve consistency and isolate transactions. 
select * from dbo.sample_cities with (readcommittedlock)
where CityName IN ('Kirkland', 'Redmond', 'Bellevue')

-- Default in Azure
-- alter database WideWorldImporters set read_committed_snapshot on

-- Not blocked
select * from dbo.sample_cities  
where CityName IN ('Kirkland', 'Redmond', 'Bellevue')

select CityName, count(*) as [Rows]
from dbo.sample_cities 
where CityName in ('Redmond', 'Bellevue', 'Kirkland')
group by CityName




