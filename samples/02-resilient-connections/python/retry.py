import os
import pyodbc
import random
import sys
import json
from tenacity import *
import logging
from dotenv import load_dotenv
 
load_dotenv(os.path.join(os.path.dirname(__file__), '.env'))

logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)
logger = logging.getLogger(__name__)

def is_retriable(value):
    RETRY_CODES = [  
        8001,   
        42000,       
        1204,   # The instance of the SQL Server Database Engine cannot obtain a LOCK resource at this time. Rerun your statement when there are fewer active users. Ask the database administrator to check the lock and memory configuration for this instance, or to check for long-running transactions.
        1205,   # Transaction (Process ID) was deadlocked on resources with another process and has been chosen as the deadlock victim. Rerun the transaction
        1222,   # Lock request time out period exceeded.
        49918,  # Cannot process request. Not enough resources to process request.
        49919,  # Cannot process create or update request. Too many create or update operations in progress for subscription "%ld".
        49920,  # Cannot process request. Too many operations in progress for subscription "%ld".
        4060,   # Cannot open database "%.*ls" requested by the login. The login failed.
        4221,   # Login to read-secondary failed due to long wait on 'HADR_DATABASE_WAIT_FOR_TRANSITION_TO_VERSIONING'. The replica is not available for login because row versions are missing for transactions that were in-flight when the replica was recycled. The issue can be resolved by rolling back or committing the active transactions on the primary replica. Occurrences of this condition can be minimized by avoiding long write transactions on the primary.

        40143,  # The service has encountered an error processing your request. Please try again.
        40613,  # Database '%.*ls' on server '%.*ls' is not currently available. Please retry the connection later. If the problem persists, contact customer support, and provide them the session tracing ID of '%.*ls'.
        40501,  # The service is currently busy. Retry the request after 10 seconds. Incident ID: %ls. Code: %d.
        40540,  # The service has encountered an error processing your request. Please try again.
        40197,  # The service has encountered an error processing your request. Please try again. Error code %d.
        10929,  # Resource ID: %d. The %s minimum guarantee is %d, maximum limit is %d and the current usage for the database is %d. However, the server is currently too busy to support requests greater than %d for this database. For more information, see http://go.microsoft.com/fwlink/?LinkId=267637. Otherwise, please try again later.
        10928,  # Resource ID: %d. The %s limit for the database is %d and has been reached. For more information, see http://go.microsoft.com/fwlink/?LinkId=267637.
        10060,  # An error has occurred while establishing a connection to the server. When connecting to SQL Server, this failure may be caused by the fact that under the default settings SQL Server does not allow remote connections. (provider: TCP Provider, error: 0 - A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond.) (Microsoft SQL Server, Error: 10060)
        10054,  # The data value for one or more columns overflowed the type used by the provider.
        10053,  # Could not convert the data value due to reasons other than sign mismatch or overflow.
        233,    # A connection was successfully established with the server, but then an error occurred during the login process. (provider: Shared Memory Provider, error: 0 - No process is on the other end of the pipe.) (Microsoft SQL Server, Error: 233)
        64,
        20,
        0
        ]
    ret = value in RETRY_CODES
    return ret

@retry(stop=stop_after_attempt(3), wait=wait_fixed(10), after=after_log(logger, logging.DEBUG))
def run_test():    
    tsql = """
            SET NOCOUNT ON;
            BEGIN TRAN; 
                INSERT INTO dbo.TestResiliency DEFAULT VALUES; 
                WAITFOR DELAY '00:00:02';
            COMMIT TRAN; 
            SELECT * FROM (VALUES (CAST(@@SPID AS INT), CAST(DATABASEPROPERTYEX(DB_NAME(DB_ID()), 'ServiceObjective') AS SYSNAME))) T(SPID, ServiceObjective) FOR JSON AUTO;"""

    while(True):
        try:
            cnxn = pyodbc.connect(os.getenv('CONNECTION_STRING'))
            cursor = cnxn.cursor()
            with cursor.execute(tsql):
                row = cursor.fetchone()
                print(json.loads(row[0]))
        except Exception as e:
            #print(e)
            if isinstance(e, pyodbc.ProgrammingError) or isinstance(e, pyodbc.OperationalError):
                if is_retriable(int(e.args[0])):
                    raise
        pass

run_test()