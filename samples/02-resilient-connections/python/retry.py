import os
import pyodbc
import random
import sys
import getopt
import json
from tenacity import *
import logging
from dotenv import load_dotenv
 
load_dotenv(os.path.join(os.path.dirname(__file__), '.env'))

logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)
logger = logging.getLogger(__name__)

def is_retriable(value):
    # Error list created from: 
    # - https://github.com/dotnet/efcore/blob/main/src/EFCore.SqlServer/Storage/Internal/SqlServerTransientExceptionDetector.cs
    # - https://docs.microsoft.com/en-us/dotnet/api/microsoft.data.sqlclient.sqlconfigurableretryfactory?view=sqlclient-dotnet-standard-4.1
    # - https://docs.microsoft.com/en-us/azure/sql-database/sql-database-develop-error-messages
    # Manually added also
    # 0, 18456
    RETRY_CODES = [  
        233, 997, 921, 669, 617, 601, 121, 64, 20, 0, 53, 258,
        1203, 1204, 1205, 1222, 1221,
        1807,
        3966, 3960, 3935,
        4060, 4221, 4891,
        8651, 8645,
        9515,
        14355,
        10929, 10928, 10060, 10054, 10053, 10936, 10929, 10928, 10922, 10051, 10065,
        11001,
        17197,
        18456,
        20041,
        41839, 41325, 41305, 41302, 41301, 40143, 40613, 40501, 40540, 40197, 49918, 49919, 49920
        ]
    ret = value in RETRY_CODES
    return ret

@retry(stop=stop_after_attempt(3), wait=wait_fixed(10), retry=retry_if_exception_type(pyodbc.Error), after=after_log(logger, logging.DEBUG))
def run_resilient_test():    
    conn_str = os.getenv('CONNECTION_STRING')
    tsql = """
            SET NOCOUNT ON;
            BEGIN TRAN; 
                INSERT INTO dbo.TestResiliency DEFAULT VALUES; 
                WAITFOR DELAY '00:00:02';
            COMMIT TRAN; 
            SELECT * FROM (VALUES (CAST(@@SPID AS INT), CAST(DATABASEPROPERTYEX(DB_NAME(DB_ID()), 'ServiceObjective') AS SYSNAME))) T(SPID, ServiceObjective) FOR JSON AUTO;"""    
    while(True):
        try:
            cnxn = pyodbc.connect(conn_str)
            cursor = cnxn.cursor()
            with cursor.execute(tsql):
                row = cursor.fetchone()
                print(json.loads(row[0])[0])
        except pyodbc.OperationalError as e:            
            logger.debug(e);
            if is_retriable(int(e.args[0])):
                raise
        except pyodbc.ProgrammingError as e:            
            logger.debug(e);            
            if is_retriable(int(e.args[0])):
                raise
        except Exception as e:
            logger.debug(type(e));  
            logger.debug(e);        
            raise    
        finally:
            cursor.close()

def run_simple_test():    
    conn_str = os.getenv('CONNECTION_STRING')
    tsql = """
            SET NOCOUNT ON;
            BEGIN TRAN; 
                INSERT INTO dbo.TestResiliency DEFAULT VALUES; 
                WAITFOR DELAY '00:00:02';
            COMMIT TRAN; 
            SELECT * FROM (VALUES (CAST(@@SPID AS INT), CAST(DATABASEPROPERTYEX(DB_NAME(DB_ID()), 'ServiceObjective') AS SYSNAME))) T(SPID, ServiceObjective) FOR JSON AUTO;"""    
    while(True):
        cnxn = pyodbc.connect(conn_str)
        cursor = cnxn.cursor()
        with cursor.execute(tsql):
            row = cursor.fetchone()
            print(json.loads(row[0]))
        cursor.close()

def usage():
    print('retry.py [-r|--resilient]|[-n|--non-resilient]')

if __name__ == "__main__":
    test_resiliency = True

    try:
        opts, args = getopt.getopt(sys.argv[1:],"rn",["resilient", "non-resilient"])
    except getopt.GetoptError:
        usage()
        sys.exit(2)
   
    for opt, arg in opts:
        logger.debug(opt)
        if opt == '-h':
            usage()
            sys.exit()
        elif opt in ("-r", "--resilient"):
            test_resiliency = True
        elif opt in ("-n", "--non-resilient"):
            test_resiliency = False
        else:
            assert False, "unhandled option"

    if test_resiliency:
        print('Running test *WITH* a resilient connection.\n')
        run_resilient_test()
    else:
        print('Running test *without* a resilient connection.\n')
        run_simple_test()
