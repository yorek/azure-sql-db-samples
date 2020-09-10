# 03 - Resilient Connections

In the cloud is of paramount importance to make sure your application can deal with transient failures. Implementing a [Retry Pattern](https://docs.microsoft.com/en-us/azure/architecture/patterns/retry) should be considered mandatory as in the cloud disconnections can happen at any time, due to resource re-allocation, temporary network issues, or even just bandwidth saturation. 

Making sure that connections to the cloud are resilient is an overall best practice, not specific to Azure SQL only. For Azure SQL, given that it handles transactional data, this is even more important, to make sure that user experience is the smoothest possible.

(Troubleshoot transient connection errors in SQL Database and SQL Managed Instance)[https://docs.microsoft.com/en-us/azure/azure-sql/database/troubleshoot-common-connectivity-issues]

This repository will help you to implement correct retry logic in your application to make them as resilient as possible.

