/*
	==========
	SETUP DEMO
	==========
*/

select databasepropertyex(db_name(), 'ServiceObjective')
go

/*
-- Run if needed
create schema [test]
go
*/

drop table if exists [test].[ORDERS];
create table [test].[ORDERS]
(
	[O_ORDERKEY] [int] not null,
	[O_CUSTKEY] [int] not null,
	[O_ORDERSTATUS] [char](1) not null,
	[O_TOTALPRICE] [decimal](15, 2) not null,
	[O_ORDERDATE] [date] not null,
	[O_ORDERPRIORITY] [char](15) not null,
	[O_CLERK] [char](15) not null,
	[O_SHIPPRIORITY] [int] not null,
	[O_COMMENT] [varchar](79) not null,
	[O_ORDERYEAR] as (datepart(year,[O_ORDERDATE])) persisted,
	[O_ORDERMONTH] as (datepart(month,[O_ORDERDATE]))
)
go

/*
-- Run if needed
drop external data source [Azure-Storage];
drop database scoped credential [Azure-Storage-Credentials]
go
*/

select * from sys.[external_data_sources] where [name] like 'Azure-Storage%'
select * from sys.[database_scoped_credentials] where [name] like 'Azure-Storage%'
go 

create database scoped credential [Azure-Storage-Credentials]
with identity = 'SHARED ACCESS SIGNATURE',
secret = ''; -- Remove starting question mark
go

create external data source [Azure-Storage]
with 
( 
	type = blob_storage,
 	location = 'https://dmstore2.blob.core.windows.net/tpch',
 	credential= [Azure-Storage-Credentials]
);

set nocount on;
go

bulk insert [test].[ORDERS]
from '10GB/orders.tbl'
with
(
	data_source = 'Azure-Storage',
	fieldterminator = '|',
	batchsize=10000
)
go

create clustered index ixc on [test].[ORDERS] (O_ORDERKEY)
go
create nonclustered index ix1 on [test].[ORDERS] (O_CUSTKEY);
create nonclustered index ix2 on [test].[ORDERS] (O_CLERK);
go

select * from sys.indexes where [object_id] = object_id('test.ORDERS')
go

/*
	========
	RUN DEMO
	========
*/

select O_CLERK, count(*) from [test].[ORDERS]  group by O_CLERK
GO

-- Get the deleted rows
delete from [TEST].[ORDERS] 
output DELETED.*
where O_CLERK = 'CLERK#000000001'
go

-- Get the updated rows
update [TEST].[ORDERS] 
set O_COMMENT = 'COMMENT HERE'
output DELETED.O_ORDERKEY, DELETED.O_COMMENT as PREV_VALUE, INSERTED.O_COMMENT as CURR_VALUE
where O_CLERK like 'CLERK#000000002'
go

-- Chunked Delete
select count(*) from [test].[ORDERS] 
where O_CLERK like 'Clerk#0000006__'
go

begin tran
go

set nocount on
while (1=1)
begin
	delete top(1000) from [test].[ORDERS]  where O_CLERK like 'CLERK#0000006__'
	if (@@ROWCOUNT = 0) break
end

rollback
go
