-- create a temporal table with an explicitly specified history table 
create table dbo.OrderInfo
(
	id int not null primary key,
	[description] nvarchar(1000) not null,
	[value] money not null,
	[received_on] datetime2 not null,
	[status] varchar(100) not null,
	customer_id varchar(10) not null,
	valid_from datetime2 not null,  
	valid_to datetime2 not null
)    
go

insert into dbo.OrderInfo values 
	(1, 'My first order', 100, '20160610', 'closed', 'DM', '20160610','9999-12-31 23:59:59.9999999')
go

alter table dbo.OrderInfo  
   add period for system_time ([valid_from], [valid_to]) 
go
  
alter table dbo.OrderInfo  
   set (system_versioning = on (history_table = dbo.OrderInfoHistory))   
; 

alter table dbo.OrderInfo 
	set ( system_versioning = off )
go

insert into dbo.OrderInfoHistory values 
	(1, 'My first order', 100, '20160601', 'received', 'DM', '20160601','20160602'),
	(1, 'My first order', 100, '20160601', 'accepted', 'DM', '20160602','20160603'),
	(1, 'My first order', 100, '20160601', 'processed', 'DM', '20160603','20160604'),
	(1, 'My first order', 100, '20160601', 'blocked', 'DM', '20160604','20160605'),
	(1, 'My first order', 100, '20160601', 'corrected', 'DM', '20160605','20160606'),
	(1, 'My first order', 100, '20160601', 'processed', 'DM', '20160606','20160607'),
	(1, 'My first order', 100, '20160601', 'prepared', 'DM', '20160607','20160608'),
	(1, 'My first order', 100, '20160601', 'in-delivery', 'DM', '20160608','20160609'),
	(1, 'My first order', 100, '20160601', 'delivered', 'DM', '20160609','20160610')
go

alter table dbo.OrderInfo 
	set ( system_versioning = on (history_table = dbo.OrderInfoHistory, data_consistency_check = on) )
go
	
select * from dbo.OrderInfo for system_time all order by valid_from
go

select * from dbo.OrderInfo for system_time as of '2016-06-08' order by valid_from
go

select * from dbo.OrderInfo for system_time from '2016-06-08' to '2016-06-10' order by valid_from
go

select * from dbo.OrderInfo for system_time between '2016-06-08' and '2016-06-10' order by valid_from
go

select * from dbo.OrderInfo for system_time contained in ('2016-06-08', '2016-06-10') order by valid_from
go
	
	
	
	
go