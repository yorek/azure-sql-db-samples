select * from dbo.Phone for system_time all
go

select * from dbo.[Address] for system_time all
go

create or alter view dbo.DenormalizedTemporalView
as
select
	a.customer_id,
	a.address,
	a.valid_from as address_valid_from,
	a.valid_to as address_valid_to,
	p.phone,
	p.valid_from as phone_valid_from,
	p.valid_to as phone_valid_to
from
	dbo.[Address] a
full join
	dbo.[Phone] p on a.customer_id = p.customer_id;
go

WITH TimeStamps AS
(
	SELECT [valid_from] AS ts FROM dbo.Phone for system_time all
	UNION ALL
	SELECT [valid_to] from dbo.Phone for system_time all
	UNION ALL
	SELECT [valid_from] FROM dbo.Address for system_time all
	UNION 
	SELECT [valid_to] FROM dbo.Address for system_time all
),
TSDR AS
(
  SELECT ts, ROW_NUMBER() OVER(ORDER BY ts) AS pos
  FROM TimeStamps
),
Intervals AS
(
  SELECT 
	[valid_from] = Cur.ts, 
	[valid_to] = Nxt.ts
  FROM 
	TSDR AS Cur
  inner JOIN 
	TSDR AS Nxt ON Nxt.pos = Cur.pos + 1
),
UnifiedValues AS
(
	SELECT 
		attr = 'phone', 
		val = phone, 
		[valid_from],
		[valid_to] 
	FROM 
		dbo.Phone for system_time all

	UNION ALL 

	SELECT 
		'address', 
		[address], 
		[valid_from], 
		[valid_to]
	FROM 
		dbo.Address for system_time all
),
ValidValues AS
(
	SELECT 
		I.[valid_from], 
		I.[valid_to], 
		V.attr, 
		V.val
	FROM 
		Intervals AS I
	JOIN 
		UnifiedValues AS V ON V.[valid_to] > I.[valid_from] AND V.[valid_from] < I.[valid_to] -- "OVERLAPS" operator
)
SELECT 
	*
FROM 
	ValidValues
PIVOT(MAX(val) FOR attr IN(phone, address)) AS P;
go

select customer_id, [address], phone 
from dbo.DenormalizedTemporalView for system_time as of '2007-12-02'
go

select customer_id, [address], phone 
from dbo.DenormalizedTemporalView for system_time as of '2007-12-20'
go

select customer_id, [address], phone 
from dbo.DenormalizedTemporalView for system_time as of '2008-01-05'
go

select customer_id, [address], phone 
from dbo.DenormalizedTemporalView for system_time as of '2021-10-20'
go







