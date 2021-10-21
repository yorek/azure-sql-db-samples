
-- create a temporal table with "anonymous" history table 
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
with (system_versioning = on) 
go

-- DML withh some sample data
insert into dbo.OrderInfo values 
(1, 'My first order', 100, sysdatetime(), 'in-progress', 'DM'),
(2, 'Another Other', 200, sysdatetime(), 'in-progress', 'IBG');

waitfor delay '00:00:03';

update dbo.OrderInfo set [status] = 'completed' where id = 1;

waitfor delay '00:00:03';

insert into dbo.OrderInfo values 
(3, 'Another one', 300, sysdatetime(), 'in-progress', 'LK');

waitfor delay '00:00:03';

delete from dbo.OrderInfo where id = 2;

-- take a look at the table schema
-- "hidden" colunns are...hidden!
select * from dbo.OrderInfo;

-- of course they exist and can be returned if requested explicitly
select id, customer_id, [description], valid_from, valid_to from dbo.OrderInfo;

-- view internal temporal table info
select [object_id], [name], [type], [type_desc], [temporal_type], [temporal_type_desc], [history_table_id] 
from sys.tables
where temporal_type = 1;

-- if needed we can actually query the history table
select * from [dbo].[MSSQL_TemporalHistoryFor_98099390]

-- using "for system time" makes it ever easier
select *, valid_from, valid_to from dbo.OrderInfo for system_time all order by id, valid_from
go

-- using "for system time" makes it ever easier
select *, valid_from, valid_to from dbo.OrderInfo for system_time as of '2021-07-19 15:50'
go

-- using "for system time" makes it ever easier
select *, valid_from, valid_to from dbo.OrderInfo for system_time as of '2021-07-19 15:49:30'
go