/*
    # Introduction
*/
go

/*
    ## View the sample timesheet data
*/
select top(10) * from dbo.timesheet
go

/*
    ## Calculate aggregations ad make it available on each row
*/
select
    *,
    sum(hours_worked) over (partition by project) as total_project_hours,
    avg(hours_worked) over (partition by project) as avg_project_hours
from
    dbo.timesheet
go

/*
    ## Multiple data partitions
*/
select
    *,
    sum(hours_worked) over (partition by project, reported_year) as total_project_hours_per_year,
    avg(hours_worked) over (partition by project, reported_year) as avg_project_hours_per_year
from
    dbo.timesheet
go

/*
    ## Running total
*/
select
    *,
    sum(hours_worked) over (
                            partition by project, reported_year 
                            order by reported_on rows between unbounded preceding and current row
                        ) as running_total_project_hours_per_year   
from
    dbo.timesheet
go

/*
    Lag, Lead, First_Value and Last_Value
*/
select
    id,
    project,
    reported_on,
    hours_worked,
    lag(reported_on) over (partition by project order by reported_on) as prev_reported,
    lead(reported_on) over (partition by project order by reported_on) as next_reported,
    first_value(reported_on) over (partition by project order by reported_on) as project_started,    
    last_value(reported_on) over (partition by project order by reported_on rows between unbounded preceding and unbounded following) as project_ended  
from
    dbo.timesheet

/*
    Any column can be accessed using lag, lead, first_value or last_value
*/
select
    id,
    project,
    reported_on,
    hours_worked,
    lag(hours_worked) over (partition by project order by reported_on) as prev_reported,
    lead(hours_worked) over (partition by project order by reported_on) as next_reported
from
    dbo.timesheet
