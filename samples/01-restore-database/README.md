# 02 - Restore Database

Azure SQL, at the moment, support .bacpac file as a medium for creating backups that can be used also outside Azure. 

> If you're not familiar with Azure, a good quickstart on how to import an Azure SQL DB using the portal or other tools is available here: https://docs.microsoft.com/en-us/azure/sql-database/sql-database-import?tabs=azure-powershell 

If you are already familiar with Azure products like Azure Blob Store and AZ CLI or Powershell, read on:

There are several ways to restore a .bacpac file to Azure: using the [SqlPackage](https://docs.microsoft.com/en-us/sql/tools/sqlpackage) tool, using [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) or using [Powershell](https://docs.microsoft.com/en-us/powershell/azure/).

> Azure SQL comes with very high security by default. Make sure your Azure SQL Server allows connection from the machine you are using. Check how to configure the firewall properly here: [Azure SQL Firewall Configuration](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-firewall-configure#from-the-database-overview-page).

## Download WideWorldImporters backup

Download the .bacpac file you want to restore on your machine. For WideWorldImporters sample database, you can find it here:

[WideWorldImporters v1.0](https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0)

Make sure you download the *Full* database `WideWorldImporters-Full`.

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

To restore .bacpac using Azure CLI you need to copy to .bacpac file into an Azure Blob Storage. If you don't have a storage account already, go on and create one:

[Create Azure Storage Account](https://docs.microsoft.com/en-us/azure/storage/common/storage-quickstart-create-account?tabs=azure-portal)

and the use Azure Storage Explorer to copy the data into an Azure Blob Container.

[Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/)

Once the .bacpac file has been copied into Azure Storage, configure the `restore-bacpac.sh` to make sure the following variables contains the correct values for your resources

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

To restore .bacpac using PowerShell you need to copy to .bacpac file into an Azure Blob Storage. If you don't have a storage account already, go on and create one:

[Create Azure Storage Account](https://docs.microsoft.com/en-us/azure/storage/common/storage-quickstart-create-account?tabs=azure-portal)

and the use Azure Storage Explorer to copy the data into an Azure Blob Container.

[Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/)

Once the .bacpac file has been copied into Azure Storage, configure the `restore-bacpac.ps1` to make sure the following variables contains the correct values for your resources

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
