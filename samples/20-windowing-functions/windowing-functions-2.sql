/*
    # Find the total amount of worked hours per project
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
    ## How much each person has contributed to the project?
*/
select
	*,
	sum(hours_worked) over (partition by project) as total_project_hours
from
	dbo.timesheet
go

/*
    ## Calculate the percentage
*/
with timesheetWithTotal as
(
    select
        *,
        sum(hours_worked) over (partition by project) as total_project_hours
    from
        dbo.timesheet
)
select
    *,
    100 * (cast(hours_worked as decimal) / total_project_hours) as contribution_perc
from
    timesheetWithTotal
go


/*
   ## Assign a row number based on contributed percentage
*/
with timesheetWithTotal as
(
    select
        *,
        sum(hours_worked) over (partition by project) as total_project_hours
    from
        dbo.timesheet
),
timesheetWithPercentage as
(
    select
        *,
        100 * (cast(hours_worked as decimal) / total_project_hours) as contribution_perc
    from
        timesheetWithTotal
)
select
	row_number() over (partition by project order by contribution_perc desc, reported_on asc) as contribution_rank,
	*
from
	timesheetWithPercentage
go

/*
    Get the first 10
*/
with timesheetWithTotal as
(
    select
        *,
        sum(hours_worked) over (partition by project) as total_project_hours
    from
        dbo.timesheet
),
timesheetWithPercentage as
(
    select
        *,
        100 * (cast(hours_worked as decimal) / total_project_hours) as contribution_perc
    from
        timesheetWithTotal
),
timesheetWithRank as
(
    select
        row_number() over (partition by project order by contribution_perc desc, reported_on asc) as contribution_rank,
        *
    from
        timesheetWithPercentage
)
select * from timesheetWithRank where contribution_rank <= 10 -- and project = 'Alpha'
go