

# Update the following variable
# to download the Full or Standart database sample
# See https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
# to have a list of available sample bacpacs
$bacpacFile="WideWorldImporters-Full.bacpac"

# Update the following variables to set the correct Azure SQL tier and the sample you want to import.
# WideWorldImporters-Full requires Premium or BusinessCritical, while
# WideWorldImporters-Standard requires Standard or GeneralPurpose
$sqlLogin=""
$sqlPassword=""
$sqlResourceGroup=""
$sqlServer=""
$sqlDatabase=""
$sqlSLO="BC_Gen5_2"
#$sqlEdition="BusinessCritical"

# Set the location to be in the same Region where your Azure SQL is
$storageLocation="WestUS2"

# Generate temporary storage account and resource group
$storageGroup=-join ((97..122) | Get-Random -Count 12 | % {[char]$_})
$storageAccount=-join ((97..122) | Get-Random -Count 12 | % {[char]$_})

# Store local path as DownloadFile needs it
$localFolder=Convert-Path .
$localBacpacFile=(Join-Path $localFolder $bacpacFile)

Write-Output "Downloading $bacpacFile..."
(New-Object System.Net.WebClient).DownloadFile(
    "https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/$bacpacFile", 
    "$localBacpacFile"
)

Write-Output "Creating temporary Resource Group '$storageGroup'..."
$sgo = New-AzResourceGroup -Name $storageGroup -Location $storageLocation

Write-Output "Creating temporary Storage Account '$storageAccount'..."
$sao = New-AzStorageAccount -ResourceGroupName $storageGroup -Name $storageAccount -SkuName Standard_LRS -Location $storageLocation
$ctx = $sao.Context

Write-Output "Creating Container..."
New-AzStorageContainer -Name "bacpac" -Context $ctx

Write-Output  "Uploading bacpac..."
Set-AzStorageBlobContent -File "$localBacpacFile" -Container "bacpac" -Blob $bacpacFile -Context $ctx

Write-Output  "Getting Storage Access Key..."
$storageKey = $(Get-AzStorageAccountKey -ResourceGroupName "$storageResourceGroup" -StorageAccountName "$storageAccount").Value[0]

Write-Output  "Importing bacpac..."
$importRequest = New-AzSqlDatabaseImport `
    -ResourceGroupName "$sqlResourceGroup" `
    -ServerName "$sqlServer" `
    -DatabaseName "$sqlDatabase" `
    -DatabaseMaxSizeBytes "$(10 * 1024 * 1024 * 1024)" `
    -StorageKeyType "StorageAccessKey" `
    -StorageKey "$storageKey" `
    -StorageUri "https://$storageAccount.blob.core.windows.net/bacpac/$bacpacFile" `
    -ServiceObjectiveName "$sqlSLO" `
    -AdministratorLogin "$sqlLogin" `
    -AdministratorLoginPassword $(ConvertTo-SecureString -String "$sqlPassword" -AsPlainText -Force)

Get-AzSqlDatabaseImportExportStatus -OperationStatusLink $importRequest.OperationStatusLink

#    -Edition "$sqlEdition" `
