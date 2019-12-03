# Azure SQL DB Samples and Best Practices

Samples and Best practices to use Azure SQL DB to build modern, mission critical application, with ease and confidence

## Running the samples

Make sure you have an Azure SQL DB database to use. If you don't have an Azure account you, you can create one for free that will also include a free Azure SQL DB tier:

https://azure.microsoft.com/en-us/free/free-account-faq/

## Sample Index

### Restore WideWorldImporters Database

Easily restore a sample database to play with Azure SQL. All the samples in this repo will require a sample database. While you can use any database you already have, by just adjusting the samples to use your tables, it is recommended to install and use the sample database WideWorldImporters as starting to point to run samples.

1. [Create Azure SQL Database](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-single-database-get-started?tabs=azure-portal)
2. [Restore WideWorldImporters from .bacpac](./samples/01-restore-database)

### Resilient Connections to Azure SQL DB

Connecting to a cloud resources means that you have to take care of managing transient errors so that your application can always provide a great user experience. 

A transient error, also known as a transient fault, has an underlying cause that soon resolves itself. An occasional cause of transient errors is when the Azure system quickly shifts hardware resources to better load-balance various workloads. Most of these reconfiguration events finish in less than 60 seconds. During this reconfiguration time span, you might have connectivity issues to SQL Database. (Ref. [Working with SQL Database connection issues and transient errors](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-connectivity-issues)).

The [Resilient Connections](./02-resilient-connections.md) samples shows how you can create applications that can gracefully handle those situations.

