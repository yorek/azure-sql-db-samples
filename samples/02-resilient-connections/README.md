# 02 - Resilient Connections

In the cloud is of paramount importance to make sure your application can deal with transient failures. Implementing a [Retry Pattern](https://docs.microsoft.com/en-us/azure/architecture/patterns/retry) should be considered mandatory as in the cloud disconnections can happen at any time, due to resource re-allocation, temporary network issues, or even just bandwidth saturation. 

Making sure that connections to the cloud are resilient is an overall best practice, not specific to Azure SQL only. For Azure SQL, given that it handles transactional data, this is even more important, to make sure that user experience is the smoothest possible.

[Troubleshoot transient connection errors in SQL Database and SQL Managed Instance](https://docs.microsoft.com/en-us/azure/azure-sql/database/troubleshoot-common-connectivity-issues)

This repository will help you to implement correct retry logic in your application to make them as resilient as possible.

## Using the Samples

To use the samples in this folder, make sure you have a database to use. An Azure SQL S0 database would be more than fine to run the tests.

```
az sql db create -g <resource-group> -s <server-name> -n resiliency_test --service-objective S0
```

Remember that if you don't have Linux environment where you can run [AZ CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) you can always use the [Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/quickstart).

[Connect to the database](https://docs.microsoft.com/en-us/azure/azure-sql/database/connect-query-content-reference-guide) using SQL Server Management Studio or Azure Data Studio and run the `./sql/00-setup.sql` to setup the table used in the test.

Now get the connection string using [the portal](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-connect-query-dotnet-core#get-adonet-connection-information-optional) or via [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/sql/db?view=azure-cli-latest#az-sql-db-show-connection-string) as it will be needed in the samples.

If you are completely new to Azure SQL, no worries! Here's a full playlist that will help you: [Azure SQL for beginners](https://www.youtube.com/playlist?list=PLlrxD0HtieHi5c9-i_Dnxw9vxBY-TqaeN).
