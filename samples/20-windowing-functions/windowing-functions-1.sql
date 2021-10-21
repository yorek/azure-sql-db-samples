/*
push compute to data

timesheet -> could really be anything. scores in an online game, logs, stock values, etc
*/

select top(10) * from dbo.timesheet


select
    *,
    sum(hours_worked) over (partition by project) as total_project_hours,
    avg(hours_worked) over (partition by project) as avg_project_hours
from
    dbo.timesheet
go

select
    *,
    sum(hours_worked) over (partition by project, reported_year) as total_project_hours_per_year,
    avg(hours_worked) over (partition by project, reported_year) as avg_project_hours_per_year
from
    dbo.timesheet
go

select
    *,
    sum(hours_worked) over (partition by project, reported_year order by reported_on rows between unbounded preceding and current row) as running_total_project_hours_per_year   
from
    dbo.timesheet
go

-- Lag and Lead
-- Developer struggle as there is no inherent ordering

select
    *,
    lag(reported_on) over (partition by project order by reported_on) as prev_reported,
    lead(reported_on) over (partition by project order by reported_on) as next_reported,
    first_value(reported_on) over (partition by project order by reported_on) as project_started    
from
    dbo.timesheet

