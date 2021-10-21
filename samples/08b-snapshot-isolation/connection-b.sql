/*
    Use WideWorldImporters Database
*/

-- Enable ability to use snapshot isolation
alter database WideWorldImporters set allow_snapshot_isolation on

-- Using the default "read committed snapshot"
begin tran
    select CityName, count(*) as [Rows]
    from dbo.sample_cities 
    where CityName in ('Redmond', 'Bellevue', 'Kirkland')
    group by CityName

    waitfor delay '00:00:15'

    select CityName, count(*) as [Rows]
    from dbo.sample_cities 
    where CityName in ('Redmond', 'Bellevue', 'Kirkland')
    group by CityName
commit

select @@trancount

-- Using the "snapshot" isolation level
set transaction isolation level snapshot
begin tran
    select CityName, count(*) as [Rows]
    from dbo.sample_cities 
    where CityName in ('Redmond', 'Bellevue', 'Kirkland')
    group by CityName

    waitfor delay '00:00:15'

    select CityName, count(*) as [Rows]
    from dbo.sample_cities 
    where CityName in ('Redmond', 'Bellevue', 'Kirkland')
    group by CityName    
commit

select @@trancount
