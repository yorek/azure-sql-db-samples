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
secret = 'sv=2019-12-12&st=2021-01-28T22%3A00%3A27Z&se=2021-01-29T22%3A00%3A27Z&sr=c&sp=rl&sig=0vLycIw%2Fmu7DK%2FZDVAd7hQMaT5B7b6Kccrahma8C6kk%3D'; -- Remove starting question mark
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

/*
	========
	RUN DEMO
	========
*/

select distinct datefromparts(year(O_ORDERDATE),1,1) from [test].[ORDERS] order by 1
go

create partition function pf_OrderDate(date)
as range right for values 
('1992-01-01', '1993-01-01', '1994-01-01', '1995-01-01', '1996-01-01', '1997-01-01', '1998-01-01')
go

create partition scheme ps_OrderDate 
as partition pf_OrderDate
all to ([Primary])
go

create clustered index IXC on [test].[ORDERS] (O_ORDERKEY, O_ORDERDATE) 
on ps_OrderDate(O_ORDERDATE) 
go

select count(*) from [test].[ORDERS] where O_ORDERDATE = '1995-02-07'
go

select $partition.pf_OrderDate('1992-01-01')
go

/*
	truncate a partition
*/
truncate table [test].[ORDERS] with (partitions (2)) 
go

select * from [test].[ORDERS] where O_ORDERDATE = '1992-01-07'
go

/*
	switch partition
*/
drop table if exists [test].[ORDERS_1995];
create table [test].[ORDERS_1995]
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

create clustered index IXC on [test].[ORDERS_1995] (O_ORDERKEY, O_ORDERDATE) 
go

alter table [test].[ORDERS_1995]
add constraint check_year_1995
check (O_ORDERDATE >= '1995-01-01' and O_ORDERDATE < '1996-01-01')
go

select $partition.pf_OrderDate('1995-01-01')
go

-- Switch Out
alter table test.[ORDERS]
switch partition 5 to test.[ORDERS_1995]
go

select * from [test].[ORDERS] where O_ORDERDATE = '1995-01-07'
go

select * from [test].[ORDERS_1995] where O_ORDERDATE = '1995-01-07'
go

-- Switch In
alter table test.[ORDERS_1995]
switch to [test].[ORDERS] partition 5
go

select * from [test].[ORDERS] where O_ORDERDATE = '1995-01-07'
go

select * from [test].[ORDERS_1995] where O_ORDERDATE = '1995-01-07'
go

