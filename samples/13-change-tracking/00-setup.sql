if not exists(select * from sys.change_tracking_databases where database_id = db_id())
begin
    alter database AzureFriday 
    set change_tracking = on
    (change_retention = 30 days, auto_cleanup = on)
end
go

drop table if exists dbo.TrainingSession;
create table dbo.TrainingSession
(
    [Id] int primary key not null,
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

insert into dbo.TrainingSession 
    (Id, RecordedOn, [Type], Steps, Distance, Duration, Calories)
values 
    (1, '20211018 17:27:23 -08:00', 'Run', 3784, 5123, 32*60+3, 526),
    (2, '20211017 17:54:48 -08:00', 'Run', 0, 4981, 32*60+37, 480)
go

alter table dbo.TrainingSession
enable change_tracking
go