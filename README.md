# Azure SQL DB Samples and Best Practices

Samples and Best practices to use Azure SQL DB to build modern, mission critical application, with ease and confidence

## Running the samples

Make sure you have an Azure SQL DB database to use. If you don't have an Azure account you, you can create one for free that will also include a free Azure SQL DB tier:

https://azure.microsoft.com/en-us/free/free-account-faq/

To create a new database, follow the instructions here:

[Create Azure SQL Database](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-single-database-get-started?tabs=azure-portal)

or, if you're already comfortable with Azure, you can just execute (using Bash, via [WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10), a Linux environment or [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview))

```bash
az group create -n <my-resource-group> -l WestUS2
az sql server create -g <my-resource-group> -n <my-server-name> -u <my-user> -p <my-password>
az sql db create -g <my-resource-group> --server <my-server-name> -n DevDB --tier BC_Gen5_2
```

## Sample Index

1. [Restore Database in Azure SQL](./samples/01-restore-database): Restoring a database in Azure SQL
2. Work in progress, will come soon :)
3. [Work with JSON](./samples/03-json-support): Working with JSON data in Azure SQL


