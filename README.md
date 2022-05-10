---
page_type: sample
languages:
- tsql
- sql
products:
- azure
- azure-sql-database
description: "Azure SQL DB Samples and Best Practices"
urlFragment: azure-sql-db-samples
---

# Azure SQL DB Samples and Best Practices
![License](https://img.shields.io/badge/license-MIT-green.svg)

<!-- 
Guidelines on README format: https://review.docs.microsoft.com/help/onboard/admin/samples/concepts/readme-template?branch=master

Guidance on onboarding samples to docs.microsoft.com/samples: https://review.docs.microsoft.com/help/onboard/admin/samples/process/onboarding?branch=master

Taxonomies for products and languages: https://review.docs.microsoft.com/new-hope/information-architecture/metadata/taxonomies?branch=master
-->

Samples and Best practices to use Azure SQL DB to build modern, mission critical applications, with ease and confidence.

## Running the samples

Make sure you have an Azure SQL DB database to use. If you don't have an Azure account you, you can create one for free that will also include a free Azure SQL DB tier:

https://azure.microsoft.com/en-us/free/free-account-faq/

To create a new database, follow the instructions here:

[Create Azure SQL Database](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-single-database-get-started?tabs=azure-portal)

or, if you're already comfortable with [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/get-started-with-azure-cli), you can just execute (using [Powershell or Command Prompt](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows), Bash, via [WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10), a Linux environment or [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview))

```bash
az group create -n <my-resource-group> -l WestUS2
az sql server create -g <my-resource-group> -n <my-server-name> -u <my-user> -p <my-password>
az sql db create -g <my-resource-group> --server <my-server-name> -n DevDB --service-objective BC_Gen5_2
```

Once the database is created, you can connect to it using [Azure Data Studio](https://docs.microsoft.com/en-us/sql/azure-data-studio). If you need help in setting up your first connection to Azure SQL with Azure Data Studio, this quick video will help you:

[How to connect to Azure SQL Database from Azure Data Studio](https://www.youtube.com/watch?v=Td_pYlRraQE)

Azure Data Studio supports Jupyter Notebooks. They will be used in some samples. If you never used them before, take a look here:

[Introduction to Azure Data Studio Notebooks](https://www.youtube.com/watch?v=Nt4kIHQ0IOc)
## Sample Index

1. [Create Database](./samples/00-create-database): Create an Azure SQL database
1. [Restore Database](./samples/01-restore-database): Restoring a database in Azure SQL
1. [Resilient Connections](./samples/02-resilient-connections): How to create resilient solutions with Azure SQL
1. [Work with JSON](./samples/03-json): Working with JSON data in Azure SQL
1. [Graph Models](./samples/04-graph): Graph model sample and references
1. [GeoSpatial Support](./samples/05-spatial): Working with GeoSpatial data in Azure SQL
1. [Key-Value Store](./samples/06-key-value): How to implement a Key-Value store with In-Memory tables
1. [Network Latency](./samples/07-network-latency): How to minimize the impact of network latency with using Azure SQL
1. [Read Committed Snapshot](./samples/08-read-committed-snapshot): With Azure SQL default isolation level writers will not block readers
1. [External Data Access](./samples/09-external-data): Importing or using external data with Azure SQL
1. [Partitioning](./samples/10-partitioning): Work In Progress
1. [Updates and Deletes](./samples/11-updates-and-deletes): Work In Progress
1. [Temporal Tables](./samples/12-temporal-tables): Work In Progress
1. [Change Tracking](./samples/13-change-tracking): Using Change Tracking to detected changed rows
1. [Change Data Capture](./samples/14-change-tracking): Using Change Data Capture to detected changed data
1. [Columnstore](./samples/15-columnstore): Work In Progress
1. [Data Masking](./samples/16-data-masking): Work In Progress
1. [Ledger Tables](./samples/17-ledger-tables): Work In Progress
1. [Row Level Security](./samples/18-row-level-security): Work In Progress
1. [Grouping Sets](./samples/19-grouping-sets): Work In Progress
1. [Windowing Functions](./samples/20-windowing-functions): Work In Progress
1. [Views](./samples/21-views): Work In Progress
1. [Stored Procedures](./samples/22-stored-procedures): Work In Progress
1. [User Defined Functions](./samples/23-user-defined-functions): Work In Progress

## Learn More

If you want to learn more on how to create modern scalable applications with Azure SQL you should read this book:

**Practical Azure SQL Database for Modern Developers**

[![Practical Azure SQL Database for Modern Developers](https://raw.githubusercontent.com/yorek/practical-azure-sql-db-for-modern-developers/master/practical-azure-sql-database-for-modern-developers-small.jpg)](https://www.apress.com/it/book/9781484263693)

that comes loaded with samples too: https://github.com/yorek/practical-azure-sql-db-for-modern-developers
