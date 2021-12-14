select databasepropertyex(db_name(), 'ServiceObjective')
go

select top(100) * from dbo.LINEITEM
go

-- Rowstore index
select format(count(*),'n0') from dbo.LINEITEM_RS
go

-- Columnstore index
select format(count(*),'n0') from dbo.LINEITEM_CS
go

-- Try to run the following aggregation query with
-- No Index 
-- RS (Rowstore)
-- CS (Columnstore)
select
    [L_ORDERKEY],
    sum(L_QUANTITY) as ORDER_QUANTITY
from
    dbo.LINEITEM_RS
group by
    [L_ORDERKEY]
having
    sum(L_QUANTITY) >= 300

-- A more complex query, useful to bucketize data
-- Is columnstore still fast?
with cte as
(
    select
        [L_ORDERKEY],
        sum(L_QUANTITY) as ORDER_QUANTITY
    from
        dbo.LINEITEM_CS
    group by
        [L_ORDERKEY]
)
select
    floor(ORDER_QUANTITY / 100) * 100 as [Range],
    count(*)
from    
    cte
group by
    floor(ORDER_QUANTITY / 100)
order by
    [Range]

-- And what if we want to return a substatinal amount of rows?
select
    [L_ORDERKEY],
    sum(L_QUANTITY) as ORDER_QUANTITY
from
    dbo.LINEITEM_CS
group by
    [L_ORDERKEY]
having
    sum(L_QUANTITY) >= 300

-- The clustered columstore is active on all columns
select
    L_SHIPMODE, count(*)
from
    dbo.LINEITEM_CS
where
    L_SHIPDATE >= '20200101'
group by
    L_SHIPMODE

set statistics io on
set statistics time on

select * from dbo.LINEITEM_RS where L_ORDERKEY = 2232932

select * from dbo.LINEITEM_CS where L_ORDERKEY = 2232932

select * from dbo.LINEITEM_RS_CS where L_ORDERKEY = 2232932

set statistics io off
set statistics time off

select
    L_SHIPMODE, sum(L_QUANTITY)
from
    dbo.LINEITEM_RS_CS
where
    L_SHIPDATE >= '20190101' and L_SHIPDATE < '20200101'   
group by
    L_SHIPMODE

insert into dbo.LINEITEM_RS_CS
select 
    [L_ORDERKEY] = 9999991, 
    [L_PARTKEY], [L_SUPPKEY], [L_LINENUMBER], [L_QUANTITY], 
    [L_EXTENDEDPRICE], [L_DISCOUNT], [L_TAX], [L_RETURNFLAG], [L_LINESTATUS], 
    [L_SHIPDATE], [L_COMMITDATE], [L_RECEIPTDATE], [L_SHIPINSTRUCT], 
    [L_SHIPMODE] = 'SEA', 
    [L_COMMENT] = 'Sample'
from dbo.LINEITEM_RS where L_ORDERKEY = 2232932

delete from dbo.LINEITEM_RS_CS where L_ORDERKEY = 9999991