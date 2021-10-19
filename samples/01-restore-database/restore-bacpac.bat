@echo off
setlocal 

@rem Make sure you have the latest DacFx version from 
@rem https://docs.microsoft.com/en-us/sql/tools/sqlpackage?view=sql-server-ver15#deployreport-parameters-and-properties

@rem Update the following variables to set the correct Azure SQL tier 
@rem depending on the sample you want to import.
@rem WideWorldImporters-Full requires Premium or BusinessCritical, while
@rem WideWorldImporters-Standard requires Standard or GeneralPurpose or Hyperscale
set azure_sql_tier="Hyperscale"
set azure_sql_slo="HS_Gen5_2"

@rem Update the following three variables
@rem to match your Azure environment and file position
set azure_sql_database=WideWorldImportersStandardCDC
set sqlpackage_path="C:\Program Files\Microsoft SQL Server\150\DAC\bin\SqlPackage.exe"
set bacpac_path="C:\Work\_dbs-backup\WideWorldImporters-Standard.bacpac"

@rem Validate input parameters
set azure_sql_server=%1
set azure_sql_login=%2
set azure_sql_password=%3

if "%azure_sql_server%"=="" (
    goto USAGE
)

if "%azure_sql_login%"=="" (
    goto USAGE
)

if "%azure_sql_password%"=="" (
    goto USAGE
)

echo Running...
%sqlpackage_path% /a:import /tcs:"Data Source=%azure_sql_server%.database.windows.net;Initial Catalog=%azure_sql_database%;User Id=%azure_sql_login%;Password=%azure_sql_password%" /sf:%bacpac_path% /p:DatabaseEdition=%azure_sql_tier% /p:DatabaseServiceObjective=%azure_sql_slo%
goto END

:USAGE
echo Usage:
echo %~nx0 azure_sql_server azure-sql-login azure-sql-password
echo Example:
echo restore-bacpac.bat sql4devs sql4devAdmin sql4devPassw0rd!
echo Note:
echo Make sure to edit %~nx0 so that variables point to the correct Azure SQL and .bacpac file.
exit /B 1

:END
endlocal
@echo on
@exit /b 0
