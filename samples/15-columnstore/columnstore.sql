select * into dbo.[LINEITEM_CS] from dbo.[LINEITEM] 

select * into dbo.[LINEITEM_RS_CS] from dbo.[LINEITEM] 


select databasepropertyex(db_name(), 'ServiceObjective')

create clustered columnstore index IXCCS on dbo.[LINEITEM_CS]

create clustered index IXC on dbo.[LINEITEM_RS_CS] ([L_ORDERKEY], [L_LINENUMBER])

create nonclustered columnstore index IXCS1 on dbo.[LINEITEM_RS_CS] ([L_LINESTATUS], [L_ORDERKEY], [L_QUANTITY], [L_SHIPMODE])

