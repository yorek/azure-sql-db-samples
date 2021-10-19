-- No order at all
select * from dbo.OrderInfo for system_time as of '2016-07-03 15:00:00'
go

-- Received
select * from dbo.OrderInfo for system_time as of '2016-09-03 10:00:00'
go

-- In-Progress
declare @d datetime2 = dateadd(day, -7, sysutcdatetime());
select *, @d as as_of_date from dbo.OrderInfo for system_time as of @d;
go

-- Now create a new temporal table and insert some customer data
create table dbo.Customer
(
	[customer_id] varchar(10) not null primary key,
	[address] nvarchar(100) not null,
	[city] nvarchar(100) not null,
	[region] nvarchar(100) not null,
	[country] nvarchar(100) not null,
	[valid_from] datetime2 not null,  
	[valid_to] datetime2 not null  
)  
go

insert into dbo.Customer values
('DM', '1st Redmond Way', 'Redmond', 'WA', 'United States', '20160801', '9999-12-31 23:59:59.9999999')
go

alter table dbo.Customer  
   add period for system_time ([valid_from], [valid_to]) 
go
  
alter table dbo.Customer  
   set (system_versioning = on (history_table = dbo.CustomerHistory))   
; 

alter table dbo.Customer 
	set ( system_versioning = off )
go

insert into dbo.CustomerHistory values 
('DM', 'Via Monte Grappa 20', 'Milano', 'Lombardia', 'Italy', '20010101', '20160801')
go

alter table dbo.Customer  
   set (system_versioning = on (history_table = dbo.CustomerHistory, data_consistency_check = on))   
; 

select * from dbo.Customer for system_time all
go

create view dbo.FlatOrderInfo
as
select
	c.[address],
	c.[city],
	c.[region],
	o.*
from
	dbo.[OrderInfo] o
inner join
	dbo.[Customer] c on [c].[customer_id] = [o].[customer_id]
go

-- Current view
select * from dbo.[FlatOrderInfo] 

-- "Magic"! :)
select * from dbo.[FlatOrderInfo] for system_time as of '20160701'
