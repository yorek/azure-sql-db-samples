------------------------------------------------------------------------
-- Topic:			SQL Server 2016 Temporal Tables
-- Author:			Davide Mauri
-- Credits:			-
-- Copyright:		Attribution-NonCommercial-ShareAlike 2.5
-- Tab/indent size:	4
-- Last Update:		2016-10-10
-- Tested On:		SQL SERVER 2016 RTM
------------------------------------------------------------------------
use [DemoTemporal]
GO

-- create a temporal table with an explicitly specified history table 
create table dbo.OrderInfoHistory
(
	id int not null,
	[description] nvarchar(1000) not null,
	[value] money not null,
	[received_on] datetime2 not null,
	[status] varchar(100) not null,
	customer_id varchar(10) not null,
	valid_from datetime2 not null,  
	valid_to datetime2 not null    
)    
go
create table dbo.OrderInfo
(
	id int not null primary key,
	[description] nvarchar(1000) not null,
	[value] money not null,
	[received_on] datetime2 not null,
	[status] varchar(100) not null,
	customer_id varchar(10) not null,
	valid_from datetime2 generated always as row start not null,  
	valid_to datetime2 generated always as row end not null,  
	period for system_time (valid_from, valid_to)     
)    
go
alter table dbo.[OrderInfo] 
set (system_versioning = on (history_table = dbo.OrderInfoHistory, data_consistency_check = on))
go

