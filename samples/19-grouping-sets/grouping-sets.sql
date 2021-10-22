/*
    Take a look at the source data
*/
select top(10) * from dbo.timesheet
go

/*
    Return data for a dashboard
*/
select 
    project, 
    month(reported_on) as [year], 
    sum(hours_worked) as hours_worked
from 
    dbo.timesheet
where
    reported_on between '20210101' and '20211231'
group by
    grouping sets
    (
        (project),
        (month(reported_on))       
    )
go

/*
    Return data for a matrix report
*/
select
    [project],
    month([reported_on]) as [month],
    sum([hours_worked]) as [hours_worked]
from
    dbo.timesheet
where
    reported_on between '20210101' and '20211231'
group by
    grouping sets
    (
        ([project], month([reported_on])),
        ([project]),
        (month([reported_on])),
        ()
    )
order by 
    [project],
    [month]
go

/*
    Return data for a matrix report in a pivoted format
*/
with reportData as
(
    select
        [project],
        month([reported_on]) as [month],
        sum([hours_worked]) as [hours_worked]
    from
        dbo.timesheet
    where
        reported_on between '20210101' and '20211231'
    group by
        grouping sets
        (
            ([project], month([reported_on])),
            ([project]),
            (month([reported_on])),
            ()
        )
)
select 
    * 
from
    reportData
pivot
    ( sum(hours_worked) for [month] in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]) ) as p
go