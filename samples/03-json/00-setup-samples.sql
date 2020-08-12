drop table if exists dbo.user_phones;
drop table if exists dbo.user_addresses;
drop table if exists dbo.users;
go

create table dbo.users
(
	id int not null primary key,
	firstName nvarchar(100) not null,
	lastName nvarchar(100) not null,
	isAlive bit not null,
	age tinyint not null
)
go

insert into dbo.users values (1, 'John', 'Smith', 1, 25)
insert into dbo.users values (2, 'Maggie', 'Doe', 1, 32)
go

create table dbo.user_addresses
(
	id int not null primary key,
	[user_id] int not null foreign key references dbo.users(id),
	streetAddress nvarchar(100) not null,
	city nvarchar(100) not null,
	[state] nvarchar(100) null,
	postalCode nvarchar(100) not null
)
go

insert into dbo.user_addresses values
(1, 1, '21 2nd Street', 'New York', 'NY', '10021-3100'),
(2, 2, '109 1st Avenue', 'London', null, 'SW1A0AA')
go

create table dbo.user_phones
(
	id int not null primary key,
	[user_id] int not null foreign key references dbo.users(id),
	[type] nvarchar(100) not null,
	number nvarchar(100) not null
)
go

insert into dbo.user_phones values
(1,1,'home','212 555-1234'),
(2,1,'office','646 555-4567'),
(3,1,'mobile','123 456-7890'),
(4,2,'home','020 7946 0891'),
(5,2,'office','020 7946 0986'),
(6,2,'mobile','123 789-4560')
go

drop table if exists dbo.users_json;
create table dbo.users_json
(
	id int not null primary key,
	json_data nvarchar(max) not null check(isjson(json_data)=1)
)
go

insert into dbo.users_json values 
(1, N'{
  "firstName": "John",
  "lastName": "Smith",
  "isAlive": true,
  "age": 25,
  "address": {
    "streetAddress": "21 2nd Street",
    "city": "New York",
    "state": "NY",
    "postalCode": "10021-3100"
  },
  "phoneNumbers": [
    {
      "type": "home",
      "number": "212 555-1234"
    },
    {
      "type": "office",
      "number": "646 555-4567"
    },
    {
      "type": "mobile",
      "number": "123 456-7890"
    }
  ],
  "children": [],
  "spouse": null
}'),
(2, N'{
  "firstName": "Maggie",
  "lastName": "Doe",
  "isAlive": true,
  "age": 32,
  "address": {
    "streetAddress": "109 1st Avenue",
    "city": "London",
    "postalCode": "SW1A0AA"
  },
  "phoneNumbers": [
    {
      "type": "home",
      "number": "020 7946 0891"
    },
    {
      "type": "office",
      "number": "020 7946 0986"
    },
    {
      "type": "mobile",
      "number": "123 789-4560"
    }
  ],
  "children": ["Annette", "Richard"],
  "spouse": "Andrew Callaghan"
}'),
(3, N'[{
  "firstName": "Mark",
  "lastName": "Brown"
},{
  "firstName": "Mike",
  "lastName": "Green" 
}]')
;
go

select * from dbo.users;
select * from dbo.user_addresses;
select * from dbo.user_phones;
select * from dbo.users_json;

