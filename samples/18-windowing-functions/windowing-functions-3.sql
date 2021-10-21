/*
    # After how many days from the start each project reached the 75% completed milestone?
*/
go

/*
    ## View the sample timesheet data
*/
select top (10)    
    *
from
    dbo.timesheet
go

/*
    ## Calculate the running total
*/
select
	*,
	sum(hours_worked) over (partition by project order by reported_on rows between unbounded preceding and current row) as hours_worked_rt
from
	dbo.timesheet
go

/*
    ## Calculate also the total amount of worked hours
*/
select
    *,
    sum(hours_worked) over (partition by project order by reported_on rows between unbounded preceding and current row) as hours_worked_rt,
    sum(hours_worked) over (partition by project) as total_project_hours
from
    dbo.timesheet
go

/*
    Calculate running percentage
*/
with timesheetWithTotals as
(
    select
        *,
        sum(hours_worked) over (partition by project order by reported_on rows between unbounded preceding and current row) as hours_worked_rt,
        sum(hours_worked) over (partition by project) as total_project_hours
    from
        dbo.timesheet    
)
select
    *,
    cast(hours_worked_rt as decimal) / total_project_hours as completed_perc
from
    timesheetWithTotals
go

/*
    Add project starting date (assuming is the first time someone reported working on the project)
*/
with timesheetWithTotals as
(
    select
        *,
        sum(hours_worked) over (partition by project order by reported_on rows between unbounded preceding and current row) as hours_worked_rt,
        sum(hours_worked) over (partition by project) as total_project_hours
    from
        dbo.timesheet    
)
select
    *,
    cast(hours_worked_rt as decimal) / total_project_hours as completed_perc,
	first_value(reported_on) over (partition by project order by reported_on rows between unbounded preceding and current row) as project_started_on
from
    timesheetWithTotals
go

/*
    Find when 75% milestone was reached
*/
with timesheetWithTotals as
(
    select
        *,
        sum(hours_worked) over (partition by project order by reported_on rows between unbounded preceding and current row) as hours_worked_rt,
        sum(hours_worked) over (partition by project) as total_project_hours
    from
        dbo.timesheet    
),
timesheetWithPercentage as
(
    select
        *,
        cast(hours_worked_rt as decimal) / total_project_hours as completed_perc,
        first_value(reported_on) over (partition by project order by reported_on rows between unbounded preceding and current row) as project_started_on
    from
        timesheetWithTotals
)
select * from timesheetWithPercentage where completed_perc >= 0.75
go

/*
    Calculate the solution
*/
/*
    Find when 75% milestone was reached
*/
with timesheetWithTotals as
(
    select
        *,
        sum(hours_worked) over (partition by project order by reported_on rows between unbounded preceding and current row) as hours_worked_rt,
        sum(hours_worked) over (partition by project) as total_project_hours
    from
        dbo.timesheet    
),
timesheetWithPercentage as
(
    select
        *,
        cast(hours_worked_rt as decimal) / total_project_hours as completed_perc,
        first_value(reported_on) over (partition by project order by reported_on rows between unbounded preceding and current row) as project_started_on
    from
        timesheetWithTotals
), timesheetFinal as
(
    select 
        row_number() over (partition by project order by completed_perc) as rn,
        *
    from 
        timesheetWithPercentage 
    where 
        completed_perc >= 0.75
)
select     
    project,
    datediff(day, project_started_on, reported_on) as elapsed_days,
    completed_perc,
    project_started_on,
    reported_on as milestone_reached_on
from 
    timesheetFinal
where
    rn = 1
go
