/*
    View Data
*/
select * from dbo.TrainingSessions
go

/*
    Get current version number
*/
select change_tracking_current_version()
go

/*
    Make some changes
*/
insert into dbo.TrainingSessions 
    (Id, RecordedOn, [Type], Steps, Distance, Duration, Calories)
values 
    (3, '20211020 18:24:32 -08:00', 'Run', 4866, 4562, 30*60+18, 475)
go

update 
    dbo.TrainingSessions 
set 
    Steps = 3450
where 
    Id = 2
go

/*
    Delete something
*/
delete from dbo.TrainingSessions where Id = 1
go

/*
    View Data
*/
select * from dbo.TrainingSessions
go

/*
    Get the current version
*/
select change_tracking_current_version()
go

/* 
    Return the changes from the requested version
*/
declare @fromVersion int = 78;
select
	sys_change_version, sys_change_operation, Id
from
	changetable(changes dbo.TrainingSessions, @fromVersion) C
go

declare @fromVersion int = 78;
select
	sys_change_version, sys_change_operation, 
    t.*
from
	changetable(changes dbo.TrainingSessions, @fromVersion) C
left outer join
    dbo.TrainingSessions t on c.Id = t.Id
go

/*
    Add couple of more rows
*/
begin tran
go

insert into dbo.TrainingSessions 
    (Id, RecordedOn, [Type], Steps, Distance, Duration, Calories)
values 
    (4, '20211021 07:35:14 -08:00', 'Run', 4123, 4234, 30*60+23, 411),
    (5, '20211021 16:32:54 -08:00', 'Run', 4568, 4780, 30*60+44, 4890);
go

update dbo.TrainingSessions 
set Calories = 489
where Id = 5
go

/*
    Update Session Id 5 again
*/
update dbo.TrainingSessions 
set Calories = 563
where Id = 5
go

commit tran
go

select @@trancount
go

/*
    Get the current version
*/
select change_tracking_current_version()
go

declare @fromVersion int = 82;
select
	sys_change_version, sys_change_operation, 
    t.*
from
	changetable(changes dbo.TrainingSessions, @fromVersion) C
left outer join
    dbo.TrainingSessions t on c.Id = t.Id
go