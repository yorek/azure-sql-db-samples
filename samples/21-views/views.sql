select
    project,
    reported_year,
    sum(hours_worked) as hours_worked
from
    dbo.timesheet
group by
    project,
    reported_year
GO

create or alter view dbo.project_totals
as
select
    project,
    reported_year,
    sum(hours_worked) as hours_worked
from
    dbo.timesheet
group by
    reported_year,
    project
go

select * from dbo.project_totals where project = 'Alpha'