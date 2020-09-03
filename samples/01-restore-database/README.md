# 01 - Restore Database in Azure SQL

Azure SQL, at the moment, support .bacpac file as a medium for creating backups that can be used also outside Azure. 

**If you're not familiar with Azure**, a good quickstart on how to import an Azure SQL DB using the portal or other tools is available here: [Quickstart: Import a BACPAC file to a database in Azure SQL Database](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-import). **If you are already familiar with Azure** products like Azure Blob Store and AZ CLI or Powershell, read on.

There are several ways to restore a .bacpac file to Azure: using the [SqlPackage](https://docs.microsoft.com/en-us/sql/tools/sqlpackage) tool, using [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) or using [Powershell](https://docs.microsoft.com/en-us/powershell/azure/).

**Azure SQL comes with very high security by default**. Make sure your Azure SQL Server allows connection from the machine you are using. Check how to configure the firewall properly here: [Azure SQL Firewall Configuration](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-firewall-configure#from-the-database-overview-page).

## Need a bit more context?

If you want learn a bit more around Azure SQL backup, restore, import and export, you can start from here: [Azure SQL & .bacpac the easy way](https://devblogs.microsoft.com/azure-sql/azure-sql-bacpac-the-easy-way)

## Download WideWorldImporters backup

Download the .bacpac file you want to restore on your machine. For WideWorldImporters sample database, you can find it here:

[WideWorldImporters v1.0](https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0)

You can download either the *Full* database `WideWorldImporters-Full` or the *Standard* one `WideWorldImporters-Standard`. Please note that the *Full* will require a Premium or Business Critical service tier to be restored. 

## Restore database using SqlPackage

Download the [SqlPackage](https://docs.microsoft.com/en-us/sql/tools/sqlpackage) tool and install it on your machine. 

Configure the file `restore-bacpac.bat` making sure that you point to the right path for the SqlPackage tool and point to the .bacpac file you want to restore.

If you're not sure where your SqlPackage tool is, you can use this command from the Windows Prompt to find it:

```text
where /R c:\ SqlPackage.exe
```

once you have updated the following variables

```text
set azure_sql_database=""
set sqlpackage_path=""
set bacpac_path=""
```

run the .bat file passing server name, login and password:

```text
restore-bacpac.bat my-server my-login my-password
```

## Restore database using Azure CLI

To restore .bacpac using Azure CLI you need to copy to .bacpac file into an Azure Blob Storage. The `restore-bacpac.sh` script will:

- create a temporary Azure Storage account for you automatically
- download the sample .bacpac via curl 
- upload it to the created Azure Storage account.
- import it into the specified Azure SQL database.
- remove the created temporary Azure Storage account

Make sure you configure the `restore-bacpac.sh` so that the following variables contains the correct values for your resources

```bash
# Specify your credentials
declare sqlLogin=""
declare sqlPassword=""

# Update the following three variables
# to match your Azure environment and file position
declare sqlResourceGroup=""
declare sqlServer=""
declare sqlDatabase=""
declare storageResourceGroup=""
declare storageAccount=""
```

then execute the script from a unix shell:

```bash
./restore-bacpac.sh
```

## Restore database using Powershell

To restore .bacpac using Powershell you need to copy to .bacpac file into an Azure Blob Storage. The `restore-bacpac.ps1` script will:

- create a temporary Azure Storage account for you automatically
- download the sample .bacpac via WebClient 
- upload it to the created Azure Storage account.
- import it into the specified Azure SQL database.
- remove the created temporary Azure Storage account

Make sure you configure the `restore-bacpac.ps1` so that the following variables contains the correct values for your resources

```powershell
# Specify your credentials
$sqlLogin=""
$sqlPassword=""

# Update the following three variables
# to match your Azure environment and file position
$sqlResourceGroup=""
$sqlServer=""
$sqlDatabase=""
$storageResourceGroup=""
$storageAccount=""
```

then execute the script from a Powershell terminal:

```powershell
./restore-bacpac.ps1
```

## Azure Storage Explorer

Azure Storage Explorer is a tool that you can use to copy the data into an Azure Blob Container.

[Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/)

