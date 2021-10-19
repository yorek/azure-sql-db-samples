create table dbo.Phone
(
	customer_id varchar(10) not null primary key,
	phone varchar(20) NOT NULL,
	valid_from datetime2 not null,  
	valid_to datetime2 not null,  
)
go

create table dbo.[Address]
(
	customer_id varchar(10) not null primary key,
	[address] varchar(100) not null,
	valid_from datetime2 not null,  
	valid_to datetime2 not null
) 
go

insert into dbo.[Phone] values ('DM', 'Phone 2', '20080202', '9999-12-31 23:59:59.9999999') 
insert into dbo.[Address] values ('DM', 'Address 2', '20071231', '9999-12-31 23:59:59.9999999');
go

alter table dbo.[Phone] add period for system_time ([valid_from], [valid_to]) 
go

alter table dbo.[Address] add period for system_time ([valid_from], [valid_to]) 
go

alter table dbo.[Phone] set (system_versioning = on (history_table = dbo.[PhoneHistory], data_consistency_check = on))   
go 

alter table dbo.[Address] set (system_versioning = on (history_table = dbo.[AddressHistory], data_consistency_check = on))   
go 

alter table dbo.[Phone] set (system_versioning = off)   
go 

alter table dbo.[Address] set (system_versioning = off)   
go 

insert into dbo.[PhoneHistory] values ('DM', 'Phone 1', '20071219', '20080202')
go

insert into dbo.[AddressHistory] values ('DM', 'Address 1', '20071201', '20071231')
go

alter table dbo.[Phone] set (system_versioning = on (history_table = dbo.[PhoneHistory], data_consistency_check = on))   
go 

alter table dbo.[Address] set (system_versioning = on (history_table = dbo.[AddressHistory], data_consistency_check = on))   
go 
