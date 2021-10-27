alter table dbo.OrderInfo set ( system_versioning = off );
drop table if exists dbo.OrderInfoHistory;
drop table if exists dbo.OrderInfo;
go

create table dbo.OrderInfo
(
	id int not null primary key,
	[description] nvarchar(1000) not null,
	[value] money not null,
	[received_on] datetime2 not null,
	[status] varchar(100) not null,
	customer_id varchar(10) not null,
	valid_from datetime2 generated always as row start hidden not null,  
	valid_to datetime2 generated always as row end hidden not null,  
	period for system_time (valid_from, valid_to)     
)    
with (system_versioning = on (history_table = dbo.OrderInfoHistory))
go

insert into dbo.OrderInfo values 
(1, 'My first order', 100, sysdatetime(), 'in-progress', 'DM'),
(2, 'Another Other', 200, sysdatetime(), 'in-progress', 'LR');

-- Time passes...

update dbo.OrderInfo set [status] = 'completed' where id = 1;

-- Time passes...

insert into dbo.OrderInfo values 
(3, 'Another one', 300, sysdatetime(), 'in-progress', 'RC');

-- Time passes...

delete from dbo.OrderInfo where id = 2;

-- Analyize the data

select * from dbo.OrderInfo

select * from dbo.OrderInfoHistory

select *, valid_from, valid_to 
from dbo.OrderInfo for system_time all
order by id, valid_from

alter table dbo.OrderInfo set ( system_versioning = off );
drop table if exists dbo.OrderInfoHistory;
drop table if exists dbo.OrderInfo;

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
	(1, 'My first order', 100, '20210610', 'closed', 'DM', '20210610','9999-12-31 23:59:59.9999999')
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
	(1, 'My first order', 100, '20210601', 'received', 'DM', '20210601','20210602'),
	(1, 'My first order', 100, '20210601', 'accepted', 'DM', '20210602','20210603'),
	(1, 'My first order', 100, '20210601', 'processed', 'DM', '20210603','20210604'),
	(1, 'My first order', 100, '20210601', 'blocked', 'DM', '20210604','20210605'),
	(1, 'My first order', 100, '20210601', 'corrected', 'DM', '20210605','20210606'),
	(1, 'My first order', 100, '20210601', 'processed', 'DM', '20210606','20210607'),
	(1, 'My first order', 100, '20210601', 'prepared', 'DM', '20210607','20210608'),
	(1, 'My first order', 100, '20210601', 'in-delivery', 'DM', '20210608','20210609'),
	(1, 'My first order', 100, '20210601', 'delivered', 'DM', '20210609','20210610')
go

alter table dbo.OrderInfo 
	set ( system_versioning = on (history_table = dbo.OrderInfoHistory, data_consistency_check = on) )
go
	
select * 
from dbo.OrderInfo for system_time all 
where id = 1
order by valid_from
go

select * from dbo.OrderInfo where id = 1 
go

select * from dbo.OrderInfo for system_time as of '2021-06-08' where id = 1  order by valid_from
go

select * from dbo.OrderInfo for system_time between '2021-06-08' and '2021-06-10'  where id = 1 order by valid_from
go
