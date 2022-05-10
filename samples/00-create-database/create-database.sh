#!/bin/bash

# Strict mode, fail on any error
set -euo pipefail

declare serverName=msfxaohkxyrfq
declare databaseName=todo_dev
declare adminUser=db_admin
declare adminPassword=AzUR3SqL_PAzzw0rd!
declare location=centralus
declare resourceGroup=dm-serverless-2021

# Create Azure SQL logical server
az sql server create -g $resourceGroup -n $serverName \
    -l $location \
    --admin-user $adminUser \
    --admin-password $adminPassword     

# Create Azure SQL database
az sql db create -g $resourceGroup -s $serverName \
    -n $databaseName \
    --service-objective S0

# Detect your public IP Address
declare myIp=`curl https://ifconfig.me/`

# Allow your IP address through the firewall
az sql server firewall-rule create --resource-group $resourceGroup --server $serverName \
    --name AllowMyClientIP \
    --start-ip-address $myIp \
    --end-ip-address $myIp

