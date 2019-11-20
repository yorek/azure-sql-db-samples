# 02 - Restore Database

Azure SQL, at the moment, support .bacpac file as a medium for creating backups that can be used also outside Azure.

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

```dos
where /R c:\ SqlPackage.exe
```

## Restore database using Azure CLI

TDB

## Restore database using Powershell

TDB