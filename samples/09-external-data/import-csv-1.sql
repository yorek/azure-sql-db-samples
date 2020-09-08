CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'A-$tr0ng|PaSSw0Rd!';
GO

/*
DROP EXTERNAL DATA SOURCE [Azure-Storage];
DROP DATABASE SCOPED CREDENTIAL [Storage-Credentials];
GO
*/

SELECT * FROM sys.[database_scoped_credentials]
GO

CREATE DATABASE SCOPED CREDENTIAL [Storage-Credentials]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = ''; -- Remove starting question mark
GO

SELECT * FROM sys.[external_data_sources]
GO

CREATE EXTERNAL DATA SOURCE [Azure-Storage]
WITH 
( 
	TYPE = BLOB_STORAGE,
 	LOCATION = 'https://myaccount.blob.core.windows.net/mycontainer', -- container can be omitted if you want to access the entire account
 	CREDENTIAL= [Storage-Credentials]
);


SELECT 
	*
FROM OPENROWSET(
	BULK 'mycontainer/csv/test.csv', -- include the container ONLY if not already in the EXTERNAL DATA SOURCE definition
	DATA_SOURCE = 'Azure-Storage',
	FIRSTROW=2,	
	FORMATFILE='mycontainer/csv/csv.fmt',
	FORMATFILE_DATA_SOURCE = 'Azure-Storage'
) as t
