/*
    Using sample "cdc_test" database (just an empty database)
*/

-- Disable CDC on table
exec sys.sp_cdc_disable_table 
		@source_schema = 'dbo',
		@source_name = 'sql_server_versions',
		@capture_instance = 'all'
go

-- Disable CDC on database
exec sys.sp_cdc_disable_db
go

-- Create Test Table
drop table if exists dbo.sql_server_versions;
create table dbo.sql_server_versions
(
	id int identity not null primary key nonclustered,
	sql_server_version varchar(10) not null unique,
	sql_server_codenames varchar(50) null
)
go

