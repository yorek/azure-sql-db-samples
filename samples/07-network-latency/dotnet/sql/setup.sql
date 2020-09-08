DROP TABLE IF EXISTS dbo.NetworkLatencyTestCustomers;
CREATE TABLE dbo.NetworkLatencyTestCustomers
(
	CustomerID INT NOT NULL PRIMARY KEY,
	Title NVARCHAR(200) NOT NULL, 
	FirstName NVARCHAR(200) NOT NULL, 
	LastName NVARCHAR(200) NOT NULL, 
	MiddleName NVARCHAR(200) NOT NULL, 
	CompanyName NVARCHAR(200) NOT NULL, 
	SalesPerson NVARCHAR(200) NOT NULL, 
	EmailAddress NVARCHAR(1024) NOT NULL, 
	Phone NVARCHAR(20) NOT NULL, 
	ModifiedDate DATETIME2(7) NOT NULL
)
GO

DROP PROCEDURE IF EXISTS dbo.InsertNetworkLatencyTestCustomers_TVP;
DROP TYPE IF EXISTS dbo.CustomerType;
CREATE TYPE dbo.CustomerType AS TABLE
(
	CustomerID INT NOT NULL PRIMARY KEY,
	Title NVARCHAR(200) NOT NULL, 
	FirstName NVARCHAR(200) NOT NULL, 
	LastName NVARCHAR(200) NOT NULL, 
	MiddleName NVARCHAR(200) NOT NULL, 
	CompanyName NVARCHAR(200) NOT NULL, 
	SalesPerson NVARCHAR(200) NOT NULL,
	EmailAddress NVARCHAR(1024) NOT NULL,
	Phone NVARCHAR(20) NOT NULL,	
	ModifiedDate DATETIME2(7) NOT NULL
)
GO

CREATE OR ALTER PROCEDURE dbo.InsertNetworkLatencyTestCustomers_Basic
	@CustomerID INT,
	@Title NVARCHAR(200),
	@FirstName NVARCHAR(200),
	@LastName NVARCHAR(200),
	@MiddleName NVARCHAR(200),
	@CompanyName NVARCHAR(200),
	@SalesPerson NVARCHAR(200),
	@EmailAddress NVARCHAR(1024),
	@Phone NVARCHAR(20),
	@ModifiedDate DATETIME2(7)
AS
INSERT INTO [dbo].[NetworkLatencyTestCustomers]
	([CustomerID], [Title], [FirstName], [LastName], [MiddleName], [CompanyName], [SalesPerson], [EmailAddress], [Phone], [ModifiedDate])
VALUES	
	(@CustomerID, @Title, @FirstName, @LastName, @MiddleName, @CompanyName, @SalesPerson, @EmailAddress, @Phone, @ModifiedDate)
GO

CREATE OR ALTER PROCEDURE dbo.InsertNetworkLatencyTestCustomers_TVP
@c AS dbo.CustomerType READONLY
AS
INSERT INTO [dbo].[NetworkLatencyTestCustomers]
	([CustomerID], [Title], [FirstName], [LastName], [MiddleName], [CompanyName], [SalesPerson], [EmailAddress], [Phone], [ModifiedDate])
SELECT
	[CustomerID]
   ,[Title]
   ,[FirstName]
   ,[LastName]
   ,[MiddleName]
   ,[CompanyName]
   ,[SalesPerson]
   ,[EmailAddress]
   ,[Phone]
   ,[ModifiedDate]
FROM
	@c
GO


CREATE OR ALTER PROCEDURE dbo.InsertNetworkLatencyTestCustomers_JSON
	@json NVARCHAR(MAX)
AS
INSERT INTO [dbo].[NetworkLatencyTestCustomers]
	([CustomerID], [Title], [FirstName], [LastName], [MiddleName], [CompanyName], [SalesPerson], [EmailAddress], [Phone], [ModifiedDate])
SELECT
	[CustomerID], [Title], [FirstName], [LastName], [MiddleName], [CompanyName], [SalesPerson], [EmailAddress], [Phone], [ModifiedDate]
FROM
	OPENJSON(@json) WITH (
		CustomerID INT,
		Title NVARCHAR(200), 
		FirstName NVARCHAR(200), 
		LastName NVARCHAR(200), 
		MiddleName NVARCHAR(200), 
		CompanyName NVARCHAR(200), 
		SalesPerson NVARCHAR(200),
		EmailAddress NVARCHAR(1024),
		Phone NVARCHAR(20),	
		ModifiedDate DATETIME2(7)
	)
GO

SELECT * FROM dbo.[NetworkLatencyTestCustomers]
