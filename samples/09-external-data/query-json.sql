/*
	Single JSON with just one document
*/
WITH cte AS
(
	SELECT
		CAST(BulkColumn AS NVARCHAR(MAX)) AS JsonData
	FROM
		OPENROWSET(BULK 'sample-data/json/sample-1.json', DATA_SOURCE = 'Azure-Storage', SINGLE_CLOB) AS AzureBlob
)
SELECT
	j.*
FROM
	cte
CROSS APPLY
	OPENJSON(cte.JsonData) j
go

/*
	Structured Results
*/
WITH cte AS
(
	SELECT
		CAST(BulkColumn AS NVARCHAR(MAX)) AS JsonData
	FROM
		OPENROWSET(BULK 'sample-data/json/sample-1.json', DATA_SOURCE = 'Azure-Storage', SINGLE_CLOB) AS AzureBlob
)
SELECT
	j.[FirstName],
	j.[LastName],
	c.[value] AS ChildName
FROM
	cte
CROSS APPLY
	OPENJSON(cte.JsonData) WITH 
	(
		FirstName NVARCHAR(100) '$.firstName',
		LastName NVARCHAR(100) '$.lastName',
		Children NVARCHAR(MAX) '$.children' AS JSON		
	) j
CROSS APPLY
	OPENJSON(j.Children) c
go

/*
	Single JSON with an array of documents, work just like before
*/
WITH cte AS
(
	SELECT
		CAST(BulkColumn AS NVARCHAR(MAX)) AS JsonData
	FROM
		OPENROWSET(BULK 'sample-data/json/sample-2.json', DATA_SOURCE = 'Azure-Storage', SINGLE_CLOB) AS AzureBlob
)
SELECT
	j.*
FROM
	cte
CROSS APPLY
	OPENJSON(cte.JsonData) j
go

	
/*
	Structured Results
*/
WITH cte AS
(
	SELECT
		CAST(BulkColumn AS NVARCHAR(MAX)) AS JsonData
	FROM
		OPENROWSET(BULK 'sample-data/json/sample-2.json', DATA_SOURCE = 'Azure-Storage', SINGLE_CLOB) AS AzureBlob
)
SELECT
	j.[FirstName],
	j.[LastName],
	c.[value] AS ChildName
FROM
	cte
OUTER APPLY
	OPENJSON(cte.JsonData) WITH 
	(
		FirstName NVARCHAR(100) '$.firstName',
		LastName NVARCHAR(100) '$.lastName',
		Children NVARCHAR(MAX) '$.children' AS JSON		
	) j
OUTER APPLY
	OPENJSON(j.Children) c