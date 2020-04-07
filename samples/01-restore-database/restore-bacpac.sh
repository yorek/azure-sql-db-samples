#!/bin/bash

# Strict mode, fail on any error
set -euo pipefail

# Update the following variable
# to download the Full or Standart database sample
# See https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
# to have a list of available sample bacpacs
declare bacpacFile="WideWorldImporters-Full.bacpac"

# Update the following variables to set the correct Azure SQL tier and the sample you want to import.
# WideWorldImporters-Full requires Premium or BusinessCritical, while
# WideWorldImporters-Standard requires Standard or GeneralPurpose or Hyperscale
declare sqlLogin=""
declare sqlPassword=""
declare sqlResourceGroup=""
declare sqlServer=""
declare sqlDatabase="WWIFULLRestoreTest"
declare sqlServiceObjective="BC_Gen5_2"

# Set the location to be in the same Region where your Azure SQL is
declare storageLocation="WestUS2"

# Generate temporary storage account and resource group
declare storageGroup=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 12 | head -n 1)
declare storageAccount=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 12 | head -n 1)

# Cleanup temporary resources on catch
set -e
trap 'catch $? $LINENO' EXIT

catch() {
  if [ "$1" != "0" ]; then    
    echo "Removing temporary resources..."
    az group delete -n $storageGroup --no-wait --yes
  fi
}

echo "Downloading $bacpacFile..."
rm $bacpacFile -f
curl https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/$bacpacFile -o ./$bacpacFile -L

echo "Creating temporary Resource Group '$storageGroup'..."
az group create -n $storageGroup -l $storageLocation

echo "Creating temporary Storage Account '$storageAccount'..."
az storage account create -g $storageGroup -n $storageAccount --sku Standard_LRS

echo "Getting created Storage Key..."
declare storageKey=$(az storage account keys list -g $storageGroup -n $storageAccount --query "[0].value" -o tsv)

# export account account and key to
export AZURE_STORAGE_KEY=$storageKey
export AZURE_STORAGE_ACCOUNT=$storageAccount

echo "Creating Container..."
az storage container create -n "bacpac" 

echo "Uploading bacpac..."
az storage blob upload -f ./$bacpacFile -c "bacpac" -n $bacpacFile

echo "Creating Azure SQL database..."
az sql db create -g $sqlResourceGroup -s $sqlServer -n $sqlDatabase  --service-objective $sqlServiceObjective

echo "Importing bacpac..."
az sql db import\
    -g $sqlResourceGroup \
    -s $sqlServer \
    -n $sqlDatabase \
    -u $sqlLogin \
    -p $sqlPassword \
    --storage-key-type StorageAccessKey \
    --storage-key $storageKey \
    --storage-uri https://$storageAccount.blob.core.windows.net/bacpac/$bacpacFile
    
   
# Delete temporary resources
echo "Deleting temporary resources..."
az group delete -n $storageGroup --no-wait --yes

echo "Done."