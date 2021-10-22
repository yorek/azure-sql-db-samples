/*
    use TPCH_10GB
*/
select databasepropertyex(db_name(), 'ServiceObjective')
go

select * into dbo.[LINEITEM_RS] from dbo.[LINEITEM] 
go

update 
	dbo.[LINEITEM_RS] 
set 
	[L_SHIPDATE] = dateadd(year, 22, [L_SHIPDATE]),
	[L_COMMITDATE] = dateadd(year, 22, [L_COMMITDATE]),
	[L_RECEIPTDATE] = dateadd(year, 22, [L_RECEIPTDATE])
go

create clustered index IXC on dbo.[LINEITEM_RS] ([L_ORDERKEY], [L_LINENUMBER])
go

select * into dbo.[LINEITEM_CS] from dbo.[LINEITEM_RS] 
go

create clustered columnstore index IXCCS on dbo.[LINEITEM_CS]
go

select * into dbo.[LINEITEM_RS_CS] from dbo.[LINEITEM_RS] 
go

create clustered index IXC on dbo.[LINEITEM_RS_CS] ([L_ORDERKEY], [L_LINENUMBER])
go

create nonclustered columnstore index IXCS1 on dbo.[LINEITEM_RS_CS] ([L_LINESTATUS], [L_ORDERKEY], [L_QUANTITY], [L_SHIPMODE])
go

