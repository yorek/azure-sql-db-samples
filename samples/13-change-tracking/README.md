# 13 - Change Tracking  

Sample on how to use [Change Tracking in Azure SQL Database](https://docs.microsoft.com/en-us/sql/relational-databases/track-changes/about-change-tracking-sql-server). Change tracking is a lightway method to get only the rows that have been inserted, updated or deleted since the last time you visited the database.

In the `App` folder you also have a working sample on how to sync Azure SQL Database into a local SQLite, using the DotMim.Sync project, that you can find here: https://github.com/Mimetis/Dotmim.Sync

If you want an full end-to-end demo of how you can use Change Tracking to build smart and efficient solution, take a look a this repo: https://github.com/azure-samples/azure-sql-db-sync-api-change-tracking/
 