-- create a temporal table with an explicitly specified history table 
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

-- DML with some sample data
insert into dbo.OrderInfo values 
(1, 'My first order', 100, sysdatetime(), 'in-progress', 'DM'),
(2, 'Another Other', 200, sysdatetime(), 'in-progress', 'IBG');

-- view the content
select *, valid_from, valid_to from dbo.OrderInfo
go

-- update a row
update dbo.OrderInfo set [status] = 'completed'
where id = 1
go

-- view the content
select *, valid_from, valid_to from dbo.OrderInfo;
select * from dbo.OrderInfoHistory;
go

-- it is also possible to have just one flattened view
select *, valid_from, valid_to from dbo.OrderInfo for system_time all order by id, valid_from
go

-- what if we're into a transaction?
begin tran
insert into dbo.OrderInfo values  (3, 'My new order', 300, sysdatetime(), 'in-progress', 'LK');
insert into dbo.OrderInfo values  (4, 'Another one', 300, sysdatetime(), 'in-progress', 'LK');
delete from dbo.OrderInfo where id = 2;
commit tran
go

select *, valid_from, valid_to from dbo.OrderInfo for system_time all order by id, valid_from
go

select * from [dbo].[OrderInfoHistory]
go

