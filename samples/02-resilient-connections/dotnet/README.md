# Azure SQL Connection Resiliency in .NET

The samples in this folder shows how to implement correct connection resiliency in your application. At the very minimum you don't need to do anything, as the Microsoft.Data.SqlClient (version 3.0 or later) will automatically help a bit by automatically handling "Idle Connections":

[Idle Connection Resiliency](https://download.microsoft.com/download/D/2/0/D20E1C5F-72EA-4505-9F26-FEF9550EFD44/Idle%20Connection%20Resiliency.docx  
)

The "Idle Connection Resiliency" is tested in the `simple` sample.

But you should *not* stop at the basics, and you should instead take care of disconnections that may happen when a query is being executed (and so the connection is not "Idle"), by coding the logic manually or using a library like Polly:

- `advanced`: manually implement a retry logic to handle transient errors
- `automatic`: use the Polly libray to automatically apply a retry logic to handle transient errors 

## Running the samples

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

then make sure you have .NET Core 6.0 installed and run

```bash
dotnet run
```

while in the `simple`, `advanced` or `automatic` folder.