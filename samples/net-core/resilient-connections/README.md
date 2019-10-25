# Connection Resiliency

This sample shows how by default, using the .NET SqlClient (ADO.NET 4.5.1 or later), connection to Azure SQL DB are made recovered automatically whenever possible, as described in this whitepaper :

https://download.microsoft.com/download/D/2/0/D20E1C5F-72EA-4505-9F26-FEF9550EFD44/Idle%20Connection%20Resiliency.docx  

https://docs.microsoft.com/en-us/azure/sql-database/sql-database-connectivity-issues 

https://docs.microsoft.com/en-us/sql/connect/ado-net/step-4-connect-resiliently-to-sql-with-ado-net?view=sql-server-ver15 

## Running the sample

Make sure you have an Azure SQL DB database to use. Get the connection string using the portal:

https://docs.microsoft.com/en-us/azure/sql-database/sql-database-connect-query-dotnet-core#get-adonet-connection-information-optional 

or via Azure CLI

https://docs.microsoft.com/en-us/cli/azure/sql/db?view=azure-cli-latest#az-sql-db-show-connection-string 

and create a new `app.config` using the `app.config.template` as a starting point. The `app.config` file will look like the following:

```json
{
    "connection-string": "<my-db-connection-string>"
}
```

then make sure you have .NET Core 2.1 installed and run

```bash
dotnet run
```

while in `./samples/resilien-connections/net-core` folder.