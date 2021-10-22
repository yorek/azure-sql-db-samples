/*
    View Data
*/
select * from dbo.TrainingSession
go

/*
    Get current version number
*/
select CHANGE_TRACKING_CURRENT_VERSION()
go

/*
    Make some changes
*/
insert into dbo.TrainingSession 
    (Id, RecordedOn, [Type], Steps, Distance, Duration, Calories)
values 
    (3, '20211020 18:24:32 -08:00', 'Run', 4866, 4562, 30*60+18, 475)
go

update 
    dbo.TrainingSession 
set 
    Steps = 3450
where 
    Id = 2

/*
    Delete someting
*/
delete from dbo.TrainingSession where Id = 1
go

/*
    View Data
*/
select * from dbo.TrainingSession
go

/*
    Get the current version
*/
select CHANGE_TRACKING_CURRENT_VERSION()
go

/* 
    Return the changes from the requested version
*/
declare @fromVersion int = 0;
select
	SYS_CHANGE_VERSION, SYS_CHANGE_OPERATION, Id
from
	changetable(changes dbo.TrainingSession, @fromVersion) C
go

declare @fromVersion int = 0;
select
	SYS_CHANGE_VERSION, SYS_CHANGE_OPERATION, 
    t.*
from
	changetable(changes dbo.TrainingSession, @fromVersion) C
left outer join
    dbo.TrainingSession t on c.Id = t.Id
go

insert into dbo.TrainingSession 
    (Id, RecordedOn, [Type], Steps, Distance, Duration, Calories)
values 
    (4, '20211021 07:35:14 -08:00', 'Run', 4123, 4234, 30*60+23, 411),
    (5, '20211021 16:32:54 -08:00', 'Run', 4568, 4780, 30*60+44, 4890);
go

update dbo.TrainingSession 
set Calories = 489
where Id = 5
go

/*
    Get the current version
*/
select CHANGE_TRACKING_CURRENT_VERSION()
go

declare @fromVersion int = 3;
select
	SYS_CHANGE_VERSION, SYS_CHANGE_OPERATION, 
    t.*
from
	changetable(changes dbo.TrainingSession, @fromVersion) C
left outer join
    dbo.TrainingSession t on c.Id = t.Id
go