# Advanced Connection Resiliency Sample

This sample shows how to properly implement a resilient connection by trapping transient errors and retrying the execution.

The sample will create three threads each one running a loop simulating a different use case:

- **Thread 1:** This thread simulates a case where best practices have been followed, keeping the connection open only for the minimum time needed.
A query is executed and the connection is opened just before execution and closed it as soon as it is finished.

- **Thread 2:** This thread simulate a connection opened way before it is needed.
A connection is open and kept open. After two seconds a query is executed on the open connection. As soon as the query is finished, the connection is closed.

- **Thread 3:** In this thread the case of a long running query is simulated. Like in Thread 1, connection is open and closed only when strictly needed, but the query executed takes two seconds to be completed.

The sample will keep the threads running in parallel in loop. You can see what happens if, for example, the Azure SQL database is asked to change its Service Level Objective by running something like:

```
ALTER DATABASE [MyDatabase] MODIFY (SERVICE_OBJECTIVE = 'S1')
```

on the target Azure SQL Database. Or if you are using a [Failover Group](https://docs.microsoft.com/en-us/azure/azure-sql/database/auto-failover-group-configure-sql-db?view=azuresql&tabs=azure-portal&pivots=azure-sql-single-db) you can try to execute a failover.

The sample application will nicely handle the disconnection, with Thread 1 usually not showing any impact at all.

Refer to the `README.md` in the upper folder to learn how to configure and run .NET samples.
