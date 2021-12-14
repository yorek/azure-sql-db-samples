create clustered index IXC on dbo.[LINEITEM_RS] ([L_ORDERKEY], [L_LINENUMBER])
go

create clustered columnstore index IXCCS on dbo.[LINEITEM_CS]
go

create clustered index IXC on dbo.[LINEITEM_RS_CS] ([L_ORDERKEY], [L_LINENUMBER])
go

create nonclustered columnstore index IXCS1 on dbo.[LINEITEM_RS_CS] ([L_LINESTATUS], [L_ORDERKEY], [L_QUANTITY], [L_SHIPMODE])
go
