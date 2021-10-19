-- Add some data
insert into dbo.OrderInfo values 
	(1, 'My first order', 100, sysdatetime(), 'in-progress', 'DM', default, default),
	(2, 'Another Other', 200, sysdatetime(), 'in-progress', 'IBG', default, default)
go
update dbo.OrderInfo set [status] = 'completed' where id = 1
go
begin tran
insert into dbo.OrderInfo values 
	(3, 'Another one', 300, sysdatetime(), 'in-progress', 'LK', default, default);
delete from dbo.OrderInfo where id = 2;
commit tran
go

-- Check the inserted data
select * from dbo.OrderInfo for system_time all order by id, valid_from
go

-- Switch off System Versioning
alter table dbo.OrderInfo set ( system_versioning = off )
go

-- It's now possible to manipulate the historical data
insert into [dbo].[OrderInfoHistory] values (1, 'My first order', 100.0, '20160601', 'received', 'DM', '20160601', '20161010');
update [dbo].[OrderInfoHistory] set valid_from = '20160910', received_on = '20160901' where id  in (1, 2) and [status] = 'in-progress';
go
select * from [dbo].[OrderInfoHistory] where id = 1 order by valid_from
go

-- Let's try to switch the System Versioning on..
alter table dbo.OrderInfo set ( system_versioning = on (history_table = [dbo].[OrderInfoHistory], data_consistency_check = on ))
go

-- Fix the inconsistency, and try again
delete from  [dbo].[OrderInfoHistory] where id = 1 and valid_from = '20160601'
insert into [dbo].[OrderInfoHistory] values (1, 'My first order', 100.0, '20160601', 'received', 'DM', '20160601', '20160910');
go
alter table dbo.OrderInfo set ( system_versioning = on (history_table = [dbo].[OrderInfoHistory], data_consistency_check = on ))
go

-- View the results
-- All Rows
select * from dbo.OrderInfo for system_time all order by id, valid_from
go
-- Current Rows
select * from dbo.OrderInfo 
go
-- Historical Rows
select * from dbo.OrderInfoHistory  order by id, valid_from
go


