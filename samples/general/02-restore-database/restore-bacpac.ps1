# Download WideWorldImporters sample database from
# https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
# and upload it to an Azure Storage Account of your choice

# Specify your credentials
$sqlLogin=""
$sqlPassword=""

# Update the following three variables
# to match your Azure enviroment and file position
$sqlResourceGroup=""
$sqlServer=""
$sqlDatabase=""
$storageResourceGroup="WideWorldImportersFull"
$storageAccount=""

$storageKey=$(Get-AzStorageAccountKey -ResourceGroupName "$storageResourceGroup" -StorageAccountName "$storageAccount").Value[0]

$importRequest = New-AzSqlDatabaseImport `
    -ResourceGroupName "$sqlResourceGroup" `
    -ServerName "$sqlServer" `
    -DatabaseName "$sqlDatabase" `
    -DatabaseMaxSizeBytes "$(10 * 1024 * 1024 * 1024)" `
    -StorageKeyType "StorageAccessKey" `
    -StorageKey "$storageKey" `
    -StorageUri "https://$storageAccount.blob.core.windows.net/WideWorldImporters-Full.bacpac" `
    -Edition "BusinessCritical" `
    -ServiceObjectiveName "BC_Gen5_2" `
    -AdministratorLogin "$sqlLogin" `
    -AdministratorLoginPassword $(ConvertTo-SecureString -String "$sqlPassword" -AsPlainText -Force)

Get-AzSqlDatabaseImportExportStatus -OperationStatusLink $importRequest.OperationStatusLink