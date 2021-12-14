select databasepropertyex(db_name(), 'ServiceObjective')
go

with cte as
(
    select
        year(L_SHIPDATE) as SHIP_YEAR,
        sum(L_QUANTITY) as TOTAL_QTY,
        sum(L_EXTENDEDPRICE*(1-L_DISCOUNT)) as TOTAL_VALUE
    from
        dbo.LINEITEM_CS
    group by
        year(L_SHIPDATE)
),
cte2 as 
(
    select
        SHIP_YEAR,
        TOTAL_QTY,
        lag(TOTAL_QTY) over (order by SHIP_YEAR) as PREV_TOTAL_QTY
    from
        cte
)
select 
    *,
    TOTAL_QTY - PREV_TOTAL_QTY as DIFF,
    format((TOTAL_QTY - PREV_TOTAL_QTY) / PREV_TOTAL_QTY, 'p') as GROWTH_RATIO
from
    cte2