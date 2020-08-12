/*
	Make sure you are using a Business Critical or Premium Service Tier
*/
select * from sys.[database_service_objectives]
go

/*
	Create In-Memory table to act as Key-Value store
*/
if (schema_id('cache') is null)
    exec('create schema [cache];')
go

create table [cache].[MemoryStore]
(
	[key] bigint not null,
	[value] nvarchar(max) null,
	index IX_Hash_Key unique hash ([key]) with (bucket_count= 100000)  
) with (memory_optimized = on,  durability = schema_only);
go

/*
	Test Key-Value GET/PUT performances
*/
create or alter procedure cache.[TestPerformance]
with native_compilation, schemabinding
as 
begin atomic with (transaction isolation level = snapshot, language = N'us_english')	
	declare @i int = 0;
    declare @o int = 0;
	while (@i < 100000)
	begin
		declare @r int = cast(rand() * 100000 as int)
	
		declare @v nvarchar(max) = (select top(1) [value] from [cache].[MemoryStore] where [key]=@r);
        set @o += 1;
	
		if (@v is not null) begin
			declare @c int = cast(json_value(@v, '$.counter') as int) + 1;
			update [cache].[MemoryStore] set [value] = json_modify(@v, '$.counter', @c) where [key] = @r
            set @o += 1;
        end else begin
			declare @value nvarchar(max) = '{"value": "' + cast(sysdatetime() as nvarchar(max)) + '", "counter": 1}'
			insert into [cache].[MemoryStore] values (@r, @value)
            set @o += 1;
		end	

		set @i += 1;
	end
    select total_operations = @o;
end
go

/*
	Run Performance Test
*/
declare @s datetime2, @e datetime2;
set @s = sysutcdatetime();
exec cache.[TestPerformance]
set @e = sysutcdatetime();
select datediff(millisecond, @s, @e)
go

/*
	See data
*/
select top 100 * from [cache].[MemoryStore]
go

/*
	Sample "GET" implementation
*/
create or alter procedure cache.[Get]
@key int
with native_compilation, schemabinding
as 
begin atomic with (transaction isolation level = snapshot, language = N'us_english')
		
	select top (1) [value] from [cache].[MemoryStore] where [key]=@key;

end
go

/*
	Sample "PUT" implementation
*/
create or alter procedure cache.[Put]
@key int,
@value nvarchar(max)
with native_compilation, schemabinding
as 
begin atomic with (transaction isolation level = snapshot, language = N'us_english')

	if (isjson(@value) != 1) throw 50000, '@value is not a JSON object', 16

	declare @f int = (select top(1) [key] from [cache].[MemoryStore] where [key]=@key);

	if (@f is not null) begin
		update [cache].[MemoryStore] set [value] = @value where [key] = @key
	end else begin
		insert into [cache].[MemoryStore] values (@key, @value)
	end	

end
go

/*
	Sample GET/PUT usage
*/
declare @json as nvarchar(max) = N'{"value": "' + cast(sysdatetime() as nvarchar(max)) + '", "counter": 1}';
exec [cache].[Put] 12345, @json;
go

exec [cache].[Get] 12345;
go

/*
	Cleanup
*/
drop procedure [cache].[Get];
drop procedure [cache].[Put];
drop procedure [cache].[TestPerformance];
drop table [cache].[MemoryStore];
drop schema [cache];
go
