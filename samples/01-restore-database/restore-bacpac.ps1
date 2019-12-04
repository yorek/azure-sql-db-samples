# Download WideWorldImporters sample database from
# https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
# and upload it to an Azure Storage Account of your choice

# Update the following variables to set the correct Azure SQL tier and the sample you want to import.
# WideWorldImporters-Full requires Premium or BusinessCritical, while
# WideWorldImporters-Standard requires Standard or GeneralPurpose
$sqlEdition="BusinessCritical"
$sqlSLO="BC_Gen5_2"
$bacpacFile="WideWorldImporters-Full.bacpac"

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

$storageKey=$(Get-AzStorageAccountKey -ResourceGroupName "$storageResourceGroup" -StorageAccountName "$storageAccount").Value[0]

$importRequest = New-AzSqlDatabaseImport `
    -ResourceGroupName "$sqlResourceGroup" `
    -ServerName "$sqlServer" `
    -DatabaseName "$sqlDatabase" `
    -DatabaseMaxSizeBytes "$(10 * 1024 * 1024 * 1024)" `
    -StorageKeyType "StorageAccessKey" `
    -StorageKey "$storageKey" `
    -StorageUri "https://$storageAccount.blob.core.windows.net/$bacpacFile" `
    -Edition "$sqlEdition" `
    -ServiceObjectiveName "$sqlSLO" `
    -AdministratorLogin "$sqlLogin" `
    -AdministratorLoginPassword $(ConvertTo-SecureString -String "$sqlPassword" -AsPlainText -Force)

Get-AzSqlDatabaseImportExportStatus -OperationStatusLink $importRequest.OperationStatusLink