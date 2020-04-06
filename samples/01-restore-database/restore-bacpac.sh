#!/bin/bash

# Strict mode, fail on any error
set -euo pipefail

# Download WideWorldImporters sample database from
# https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
# and upload it to an Azure Storage Account of your choice

# Update the following variable
# to download the Full or Standart database sample
declare bacpacFile="WideWorldImporters-Full.bacpac"

# Set the location to be in the same Region where your Azure SQL is
declare storageLocation="WestUS2"

echo "Downloading $bacpacFile..."
rm $bacpacFile -f
curl https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/$bacpacFile -o ./$bacpacFile

echo "Creating temporary Resource Group..."
declare storageGroup=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 12 | head -n 1)
az group create -n $storageGroup -l $storageLocation

echo "Creating temporary Storage Account..."
declare storageAccount=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 12 | head -n 1)
az storage account create -g $storageGroup -n $storageAccount --sku Standard_LRS

# Specify your credentials
declare sqlLogin=""
declare sqlPassword=""

# Update the following variables to set the correct Azure SQL tier and the sample you want to import.
# WideWorldImporters-Full requires Premium or BusinessCritical, while
# WideWorldImporters-Standard requires Standard or GeneralPurpose
declare sqlResourceGroup=""
declare sqlServer=""
declare sqlDatabase=""
declare sqlServiceObjective="BC_Gen5_2"

declare storageKey=$(az storage account keys list -g $storageGroup -n $storageAccount --query "[0].value" -o tsv)

az sql db create -g $sqlResourceGroup -s $sqlServer -n $sqlDatabase  --service-objective $storageResourceGroup

az sql db import\
    -g $sqlResourceGroup \
    -s $sqlServer \
    -n $sqlDatabase \
    -u $sqlLogin \
    -p $sqlPassword \
    --storage-key-type StorageAccessKey \
    --storage-key $storageKey \    
    --storage-uri https://$storageAccount.blob.core.windows.net/$bacpacFile
    
    
