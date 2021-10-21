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

-- what if we're into a transaction?
print  sysutcdatetime();
begin tran;
	waitfor delay '00:00:03';
	insert into dbo.OrderInfo values  (100, 'Order 1', 300, sysutcdatetime(), 'new', 'DM');
	insert into dbo.OrderInfo values  (200, 'Order 2', 300, sysutcdatetime(), 'new', 'DM');
	waitfor delay '00:00:03'
	insert into dbo.OrderInfo values  (300, 'Order 3', 300, sysutcdatetime(), 'new', 'DM');
commit tran
print  sysutcdatetime();
go

select *, valid_from, valid_to from dbo.OrderInfo
go

-- truncate table dbo.OrderInfo -> NOT SUPPORTED!
delete from dbo.OrderInfo
go

-- and what about nested transactions?
print  sysutcdatetime();
begin tran;
waitfor delay '00:00:03';
insert into dbo.OrderInfo values  (100, 'Order 100', 300, sysutcdatetime(), 'new', 'DM');
insert into dbo.OrderInfo values  (200, 'Order 200', 300, sysutcdatetime(), 'new', 'DM');
waitfor delay '00:00:03';
begin tran;
insert into dbo.OrderInfo values  (300, 'Order 300', 300, sysutcdatetime(), 'new', 'DM');
commit tran;
commit tran;
go

select *, valid_from, valid_to from dbo.OrderInfo
go

delete from dbo.OrderInfo
go

-- enough with inserts..and the updates/deletes?
begin tran;
insert into dbo.OrderInfo values  (1000, 'Order 1000', 300, sysutcdatetime(), 'new', 'DM');
waitfor delay '00:00:03';
update dbo.OrderInfo set [description] = 'Updated Order 1000' where id = 1000;
commit tran;
go

-- check results
select *, valid_from, valid_to from dbo.OrderInfo for system_time all where id = 1000;
select * from dbo.OrderInfoHistory where id = 1000;
go

-- and deletes?
begin tran;
insert into dbo.OrderInfo values  (1001, 'Order 1001', 300, sysutcdatetime(), 'new', 'DM');
waitfor delay '00:00:03';
update dbo.OrderInfo set  [description] = 'Updated Order 1001' where id = 1001;
waitfor delay '00:00:03';
delete from dbo.OrderInfo where id = 1001
commit tran;
go

-- check results
select *, valid_from, valid_to from dbo.OrderInfo for system_time all where id = 1001;
select * from dbo.OrderInfoHistory where id = 1001;
go

-- nested trasactions?
begin tran;
insert into dbo.OrderInfo values  (1002, 'Order 1002', 300, sysutcdatetime(), 'new', 'DM');
waitfor delay '00:00:03';
begin tran
update dbo.OrderInfo set  [description] = 'Updated Order 1002' where id = 1002;
commit tran
waitfor delay '00:00:03';
delete from dbo.OrderInfo where id = 1002
commit tran;
go

-- check results
select *, valid_from, valid_to from dbo.OrderInfo for system_time all where id = 1002;
select * from dbo.OrderInfoHistory where id = 1002;
go
