#!/bin/bash

# Strict mode, fail on any error
set -euo pipefail

declare serverName=msfxaohkxyrfq
declare databaseName=todo_dev
declare adminUser=db_admin
declare adminPassword=AzUR3SqL_PAzzw0rd!
declare location=centralus
declare resourceGroup=dm-serverless-2021

az sql server create -g $resourceGroup -n $serverName \
    -l $location \
    --admin-user $adminUser \
    --admin-password $adminPassword     

az sql db create -g $resourceGroup -s $serverName \
    -n $databaseName \
    --service-objective S0

declare myIp=`curl https://ifconfig.me/`

az sql server firewall-rule create --resource-group $resourceGroup --server $serverName \
    --name AllowMyClientIP_1 \
    --start-ip-address $myIp \
    --end-ip-address $myIp

