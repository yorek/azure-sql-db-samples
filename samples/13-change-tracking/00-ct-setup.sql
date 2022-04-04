/*
    Using sample "ct_sample" database (just an empty database)
*/

/* 
    Enable Change Tracking if not enabled yet
*/
if not exists(select * from sys.change_tracking_databases where database_id = db_id())
begin
    alter database ct_sample set change_tracking = on (change_retention = 30 days, auto_cleanup = on)
end
go

/*
    Check that Change Tracking has been enabled
*/
select * from sys.change_tracking_databases
go

/* 
    Create sequence
*/
if not exists(select * from sys.sequences where [name] = 'Ids')
begin
    create sequence dbo.Ids
    as int
    start with 1000;
end
go

/* 
    Create a table
*/
drop table if exists dbo.TrainingSessions;
create table dbo.TrainingSessions
(
    [Id] int primary key not null default(next value for dbo.Ids),
    [RecordedOn] datetimeoffset not null,
    [Type] varchar(50) not null,
    [Steps] int not null,
    [Distance] int not null, --Meters
    [Duration] int not null, --Seconds
    [Calories] int not null,
    [PostProcessedOn] datetimeoffset null,
    [AdjustedSteps] int null,
    [AdjustedDistance] decimal(9,6) null
);
go

/*
    Insert some initial values
*/
insert into dbo.TrainingSessions 
    (Id, RecordedOn, [Type], Steps, Distance, Duration, Calories)
values 
    (1, '20211018 17:27:23 -08:00', 'Run', 3784, 5123, 32*60+3, 526),
    (2, '20211017 17:54:48 -08:00', 'Run', 0, 4981, 32*60+37, 480)
go

/*
    Now enable Change Tracking *on the table*
*/
alter table dbo.TrainingSessions enable change_tracking
go

/*
    Verify that Change Tracking has been enabled
*/
select 
    quotename(object_schema_name([object_id])) + N'.' + quotename(object_name([object_id])) as table_name, 
    * 
from
    sys.change_tracking_tables




