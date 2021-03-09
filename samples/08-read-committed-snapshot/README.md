# 08 - Read Committed Snapshot

By default Azure SQL database uses the `READ COMMITTED SNAPSHOT` isolation level. With that level "the Database Engine uses row versioning to present each statement with a transactionally consistent snapshot of the data as it existed at the start of the statement. Locks are not used to protect the data from updates by other transactions."

https://docs.microsoft.com/en-us/sql/t-sql/statements/set-transaction-isolation-level-transact-sql?view=azuresqldb-current

Long story short: writes will not block reads.

To test it yourself, run the `connection-a.sql` on `WideWorldImporters` database on Azure SQL and, before running the `ROLLBACK TRAN`, open another connection to the same Azure SQL and database and run the `connection-b.sql` script. You will see that, even the transaction opened by connection "a" is not finished yet, the connection "b" can still access data. More specifically connection "b" is access the latest committed data, which is unaffected by changes done in connection "a" as that transaction has not been committed.