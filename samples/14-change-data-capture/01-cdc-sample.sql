/*
    Using sample "cdc_test" database (just an empty database)
*/

-- start from an empty table
truncate table dbo.sql_server_versions;
select * from dbo.sql_server_versions;
go

-- insert some initial values
insert into 
	dbo.sql_server_versions (sql_server_version, sql_server_codenames) 
values 
	('1.0', null),
	('1.1', null),
	('4.2', null),
	('4.21', 'SQLNT'),
	('5.0', null),  -- Never existed!
	('6.0', 'Unknown'), 
	('6.5', 'Hydra'), 
	('7', 'Sphinx'), 
	('2000', 'Unknown'),
	('2008', 'Katmai'),
	('2008 R2', 'Kilimanjaro'),
	('2012', 'Denali')
go

-- view values
select * from dbo.sql_server_versions
go

-- enable cdc on database
exec sys.sp_cdc_enable_db;
go

-- CDC-related system objects
select * from sys.objects where schema_id = schema_id('cdc')

-- enable cdc on target table
exec sys.sp_cdc_enable_table
		@source_schema = 'dbo',
		@source_name = 'sql_server_versions',
		@role_name = 'cdc_user', -- everyone (except sysadmin and db_owners) must be member of this role to access change tables
		@supports_net_changes = 1; -- all generate "get_net_changes' procedure'
go

-- CDC newly created system objects
select * from sys.objects where schema_id = schema_id('cdc') and [name] like '%sql[_]server[_]versions%'

-- verify that cdc is enabled on table
select is_tracked_by_cdc from sys.[tables] as t where t.[name] = 'sql_server_versions'
go

-- list all tables on which CDC has been enabled
exec sys.sp_cdc_help_change_data_capture

-- note that no changes has been made to the table
select * from dbo.[sql_server_versions] as ssv
go

-- Insert missing 2005 version with a mispelled value
insert into dbo.[sql_server_versions] (
	[sql_server_version],
	[sql_server_codenames]
)  values ('2005', 'Iucon')
go

-- Update value
begin tran
insert into dbo.[sql_server_versions] ([sql_server_version], [sql_server_codenames]) values ('5.5', 'Unknown') -- There is no such version!
update dbo.sql_server_versions set sql_server_codenames = 'Yukon' where sql_server_version = '2005';
update dbo.sql_server_versions set sql_server_codenames = 'Shiloh' where sql_server_version = '2000';
update dbo.sql_server_versions set sql_server_codenames = 'SQL95' where sql_server_version = '6.0';
waitfor delay '00:00:03'; -- wait some seconds
commit
go

-- Get some internal CDC info on transaction log scan
select * from sys.dm_cdc_log_scan_sessions
select * from sys.dm_cdc_errors

-- Update value
update dbo.sql_server_versions set sql_server_codenames = 'Test' where sql_server_version = '5.0';
go

-- Insert new values
insert into 
	dbo.sql_server_versions ([sql_server_version], [sql_server_codenames]) 
values 
	('2014', null),
	('2016', null),
	('2017', 'Helsinki'),
	('2019', 'Seattle')
go

-- Update missing values
update dbo.sql_server_versions set sql_server_codenames = 'SQL' + right(sql_server_version,2)  where sql_server_version in ('2014', '2016');
go

-- Delete a value
delete from dbo.sql_server_versions where sql_server_version in ('5.0', '5.5')
go

-- note that no changes has been made to the table
select * from dbo.[sql_server_versions] as ssv
go

-- Get some internal CDC info on transaction log scan
select * from sys.dm_cdc_log_scan_sessions
select * from sys.dm_cdc_errors

-- display all changes (with before and after values) made between the given lsns
declare @from_lsn binary(10) = sys.[fn_cdc_get_min_lsn]('dbo_sql_server_versions')
declare @to_lsn binary(10) = sys.[fn_cdc_get_max_lsn]()

select 
	operation  = 
		case __$operation
			when 1 then 'DELETE'
			when 2 then 'INSERT'
			when 3 then 'UPDATE (Before Value)'
			when 4 then 'UPDATE (After Value)'
			else 'Nothing Else!'
		end, 	
	* 
from 
	cdc.fn_cdc_get_all_changes_dbo_sql_server_versions(@from_lsn, @to_lsn, 'all update old');
go

-- Map LSNs to time
select
	min_lsn = sys.[fn_cdc_get_min_lsn]('dbo_sql_server_versions'), 
	max_lsn = sys.[fn_cdc_get_max_lsn](),
	min_time = sys.fn_cdc_map_lsn_to_time(sys.[fn_cdc_get_min_lsn]('dbo_sql_server_versions')), 
	max_time = sys.fn_cdc_map_lsn_to_time(sys.[fn_cdc_get_max_lsn]())
go

-- Map time to LSNs
select sys.fn_cdc_map_time_to_lsn('smallest greater than or equal', '2022-04-03 23:47:10.233')
go

select * from cdc.dbo_sql_server_versions_CT


-- display *net* changes 
declare @from_lsn binary(10) = sys.[fn_cdc_get_min_lsn]('dbo_sql_server_versions')
declare @to_lsn binary(10) = sys.[fn_cdc_get_max_lsn]()

select 
	operation  = 
		case __$operation
			when 1 then 'DELETE'
			when 2 then 'INSERT'
			when 3 then 'UPDATE (Before Value)'
			when 4 then 'UPDATE (After Value)'
			else 'Nothing Else!'
		end, 	
	* 
from 
	cdc.fn_cdc_get_net_changes_dbo_sql_server_versions(@from_lsn, @to_lsn, 'all');
go

-- display net changes with some additional metadata
-- the following select statement assure us that we have an "UPDATE" as a net result. 
-- Basically we start to calculate the net changes from the first non-insert statement recorded,
-- otherwise a command sequence like INSERT -> UPDATE will always result in a INSERT net change
-- The __$update_mask has some value only for UPDATE opertions.
declare @from_lsn binary(10) = (select top 1 __$start_lsn from cdc.dbo_sql_server_versions_CT where __$operation = 3 order by __$start_lsn)
declare @to_lsn binary(10) = sys.[fn_cdc_get_max_lsn]()

select 
	operation = 
		case __$operation
			when 1 then 'DELETE'
			when 2 then 'INSERT'
			when 3 then 'UPDATE (Before Value)'
			when 4 then 'UPDATE (After Value)'
			else 'Nothing Else!'
		end, 	
	version_column_changed = sys.fn_cdc_is_bit_set(sys.fn_cdc_get_column_ordinal(N'dbo_sql_server_versions', N'sql_server_version'), __$update_mask),
	codename_column_changed = sys.fn_cdc_is_bit_set(sys.fn_cdc_get_column_ordinal(N'dbo_sql_server_versions', N'sql_server_codenames'), __$update_mask),
	* 
from 
	cdc.fn_cdc_get_net_changes_dbo_sql_server_versions(@from_lsn, @to_lsn, 'all with mask');
go

-- Change table schema
alter table dbo.[sql_server_versions]
alter column sql_server_codenames varchar(100) null
go

alter table dbo.[sql_server_versions]
add release_year int null
go

create clustered index ixc on dbo.[sql_server_versions] (release_year)
go

-- Add values for new column
update 
	t
set
	t.release_year = s.release_year
from
	dbo.[sql_server_versions] as t
inner join
	(values 
		(1989, '1.0'),
		(1990, '1.1'),
		(1992, '4.2'),
		(1993, '4.21'),
		(1995, '6.0'),
		(1996, '6.5'),
		(1998, '7'),
		(2000, '2000'),
		(2005, '2005'),
		(2008, '2008'),
		(2010, '2008 R2'),
		(2012, '2012'),
		(2014, '2014'),
		(2016, '2016'),
		(2017, '2017'),
		(2019, '2019')
	) s(release_year, sql_server_version) 
on
	s.sql_server_version = t.sql_server_version
go

select * from dbo.[sql_server_versions] as ssv order by release_year
go

-- Read changed schema informations
exec sys.[sp_cdc_get_ddl_history] @capture_instance = 'dbo_sql_server_versions'

-- Disable CDC on table
exec sys.sp_cdc_disable_table 
		@source_schema = 'dbo',
		@source_name = 'sql_server_versions',
		@capture_instance = 'all'
go

-- Disable CDC on database
exec sys.sp_cdc_disable_db
go
