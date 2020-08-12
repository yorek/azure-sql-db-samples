/*
	Use Metrodata
*/
select * from sys.[database_service_objectives]
go

select top (10) *, Location.ToString() from dbo.[BusData2] 
where cast([TimestampLocal] as date) = '2020-08-11'
order by Id desc
go

with cte as
(
	select top (10)
		*
	from
		dbo.[BusData2]
	where
		[VehicleId] = 7319
	and 
		[Signage] = '221 REDMOND TC'
	and
		cast([TimestampLocal] as date) = '2020-08-11'
	order by
		Id desc
)
select 
	geography::UnionAggregate([Location]).ToString() 
from 
	cte
go


declare @gf as geography = geography::STGeomFromText(
	'POLYGON((-122.14357282700348 47.616901066671886,-122.141025341366 47.61685232450776,-122.14101421569923 47.617249758593886,-122.14283305463597 47.61725350816795,-122.14283861681452 47.61845704045888,-122.14351164303936 47.6184795362212,-122.14357282700348 47.616901066671886))',
	4326
);
select top (50)
	Id, [VehicleId], [Signage], [TimestampLocal], [Location].ToString(), geography::STGeomCollFromText('GEOMETRYCOLLECTION(' + [Location].ToString() + ', ' + @gf.ToString() + ')', 4326).ToString()
from
	dbo.[BusData2]
where
	[Signage] = '221 EDUCATION HILL'
and
	cast([TimestampLocal] as date) = '2020-08-10'
and
	[Location].STWithin(@gf) = 1
order by
	Id desc
go

declare @gf as geography = geography::STGeomFromText(
	'POLYGON((-122.14357282700348 47.616901066671886,-122.141025341366 47.61685232450776,-122.14101421569923 47.617249758593886,-122.14283305463597 47.61725350816795,-122.14283861681452 47.61845704045888,-122.14351164303936 47.6184795362212,-122.14357282700348 47.616901066671886))',
	4326
);
with cte as
(
	select top (100)
		*
	from
		dbo.[BusData2]
	where
		[VehicleId] = 7364
	and 
		[Signage] = '221 EDUCATION HILL'
	and
		[TimestampLocal] between '2020-08-10 11:30:00 -07:00' and '2020-08-10 12:30:00 -07:00'
	and
		[Location].STWithin(@gf) = 1
	order by
		Id desc
)
select 
	geography::STGeomCollFromText('GEOMETRYCOLLECTION(' + geography::UnionAggregate([Location]).ToString() + ', ' + @gf.ToString() + ')', 4326).ToString() 
from 
	cte
go