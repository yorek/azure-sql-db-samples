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
go

alter table dbo.OrderInfo
add [shipped_on] datetime2 null
go

alter table dbo.OrderInfo
add [quantity] int not null default(0)
go

update dbo.OrderInfo set quantity = 10 where id = 1
go

insert into dbo.OrderInfo 	
	(id, [description], [value], received_on, [status], customer_id, valid_from, valid_to, shipped_on, quantity)
values
	(3, 'Yet another one', 300, sysdatetime(), 'received', 'DM', default, default, null, 10)
go

select * from dbo.[OrderInfo]
select * from dbo.[OrderInfoHistory]
go

alter table dbo.OrderInfo
drop constraint DF__OrderInfo__quant__3E1D39E1
go

alter table dbo.OrderInfo
drop column quantity
go

select * from dbo.[OrderInfo]
select * from dbo.[OrderInfoHistory]
go
