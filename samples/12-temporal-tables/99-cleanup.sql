if (objectpropertyex(object_id('dbo.Phone'), N'TableTemporalType') = 2)
	alter table dbo.Phone set ( system_versioning = off )
go

if (objectpropertyex(object_id('dbo.Address'), N'TableTemporalType') = 2)
	alter table dbo.[Address] set ( system_versioning = off )
go

if (objectpropertyex(object_id('dbo.OrderInfo'), N'TableTemporalType') = 2)
	alter table dbo.OrderInfo set ( system_versioning = off )
go

if (objectpropertyex(object_id('dbo.Customer'), N'TableTemporalType') = 2)
	alter table dbo.Customer set ( system_versioning = off )
go

drop table if exists dbo.Phone;
drop table if exists dbo.PhoneHistory;
go
drop table if exists dbo.[Address];
drop table if exists dbo.[AddressHistory];
go
drop view if exists dbo.DenormalizedTemporalView;
go
drop table if exists dbo.Customer
drop table if exists dbo.CustomerHistory
go
drop table if exists dbo.OrderInfo
drop table if exists dbo.OrderInfoHistory
go

declare @cmd nvarchar(max);
declare c cursor fast_forward for
select 'DROP TABLE dbo.' + quotename([name]) from sys.tables where [name] like 'MSSQL_Temporal%';
open c;
fetch next from c into @cmd
while (@@FETCH_STATUS = 0)
begin	
	exec(@cmd);
	fetch next from c into @cmd;
end;
close c;
deallocate c;
