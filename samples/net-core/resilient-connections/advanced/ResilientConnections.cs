using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Threading.Tasks;
using Dapper;

namespace AzureSQL.DevelopmentBestPractices
{
    class ExecutionInfo {
        public int ServerProcessId = 0;
        public string ServiceLevelObjective = String.Empty;

        public override string ToString() {
            return $"SPID: {ServerProcessId}, SLO: {ServiceLevelObjective}";
        }
    }

    class ResilientConnectionSample
    {     
        // Added all error code listed here: "https://docs.microsoft.com/en-us/azure/sql-database/sql-database-develop-error-messages"
        // Added Error Code 0 to automatically handle killed connections
        // Added Error Code 4891 to automatically handle "Insert bulk failed due to a schema change of the target table" error
        // Added Error Code 10054 to handle "The network path was not found" error that could happen if connection is severed (e.g.: cable unplugged)
        // Added Error Code 53 to handle "No such host is known" error that could happen if connection is severed (e.g.: cable unplugged)
        // Added Error Code 11001 to handle transient network errors
        // Added Error Code 10065 to handle transient network errors
        // Added Error Code 10060 to handle transient network errors
        // Added Error Code 121 to handle transient network errors
        // Added Error Code 258 to handle transient login errors

        private readonly List<int> _transientErrors = new List<int>() { 
                0, 53, 121, 258, 4891, 10054, 18456, 4060, 40197, 40501, 40613, 49918, 49919, 49920, 10054, 11001, 10065, 10060, 10051
            };
        private int _maxAttempts = 5;
        private int _delay = 5; // seconds

        private string _connectionString = "";
      
        public ResilientConnectionSample(string connectionString)
        {
            _connectionString = connectionString;
        }

        public void RunSample()
        {
            do {
                ExecuteSampleQuery();                
            } while (true);
        }

        public void ExecuteSampleQuery()
        {
            int attempts = 0;      
            int waitTime = attempts * _delay;

            while (attempts < _maxAttempts)
            {
                attempts += 1;
                
                SqlConnection conn = null;                
                var csb = new SqlConnectionStringBuilder(_connectionString);                
                csb.ConnectTimeout = waitTime;
                try
                {                    
                    conn = new SqlConnection(_connectionString);                            
                    var ei = conn.QuerySingle<ExecutionInfo>(
                        "INSERT INTO dbo.TestResiliency DEFAULT VALUES; WAITFOR DELAY '00:00:02'; SELECT @@SPID AS ServerProcessId, DATABASEPROPERTYEX(DB_NAME(DB_ID()), 'ServiceObjective') AS ServiceLevelObjective",
                        commandTimeout: waitTime
                        );
                    Console.WriteLine($"{DateTime.Now.ToString("o")} > {ei}");
                    attempts = int.MaxValue;
                }
                catch (SqlException se)
                {
                    if (_transientErrors.Contains(se.Number))
                    {
                        waitTime = attempts * _delay;

                        Console.WriteLine($"Transient error caught. Waiting {waitTime} seconds and then trying again...");
                        Console.WriteLine($"Error: [{se.Number}] {se.Message}");

                        Task.Delay(waitTime * 1000).Wait();
                    }
                    else
                    {
                        Console.WriteLine($"Unmanaged Error: [{se.Number}] {se.Message}");
                        throw;
                    }
                }
                finally {
                    conn?.Close();
                }
            }
        }
    }
}
