using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.Data.SqlClient;
using System.Threading;
using System.Threading.Tasks;
using Dapper;

namespace AzureSQL.DevelopmentBestPractices
{
    class ExecutionInfo
    {
        public int ServerProcessId = 0;
        public string ServiceLevelObjective = String.Empty;

        public override string ToString()
        {
            return $"SPID: {ServerProcessId}, SLO: {ServiceLevelObjective}";
        }
    }

    class SampleOptions
    {
        public int SampleId = 0;        
        public int SecondsConnectionStayOpen = 0;
        public int SecondsBetweenQueries = 0;
        public int SecondsQueryWillExecute = 0;
        public CancellationToken Token = CancellationToken.None;
    }

    class ResilientConnectionSample
    {
        // Error list created from: 
        // - https://github.com/dotnet/efcore/blob/main/src/EFCore.SqlServer/Storage/Internal/SqlServerTransientExceptionDetector.cs
        // - https://docs.microsoft.com/en-us/dotnet/api/microsoft.data.sqlclient.sqlconfigurableretryfactory?view=sqlclient-dotnet-standard-4.1
        // - https://docs.microsoft.com/en-us/azure/sql-database/sql-database-develop-error-messages
        // Manually added also
        // 0, 18456
        private static List<int> _transientErrors = new List<int> { 
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
            var source = new CancellationTokenSource();
            var token = source.Token;

            var tests = new List<SampleOptions>();

            tests.Add(new SampleOptions() {
                SampleId = 1,
                SecondsBetweenQueries = 2,
                SecondsConnectionStayOpen = 0,
                SecondsQueryWillExecute = 0,
                Token = token                
            });

            tests.Add(new SampleOptions() {
                SampleId = 2,
                SecondsBetweenQueries = 0,
                SecondsConnectionStayOpen = 2,
                SecondsQueryWillExecute = 0,
                Token = token                
            });

             tests.Add(new SampleOptions() {
                SampleId = 3,
                SecondsBetweenQueries = 0,
                SecondsConnectionStayOpen = 0,
                SecondsQueryWillExecute = 2,
                Token = token                
            });

            var tasks = new List<Task>();
            foreach(var t in tests)
            {
                tasks.Add(Task.Run(() => ExecuteSampleQuery(t)));
            }
            
            Console.WriteLine("Press any key to terminate the application...");
            Console.ReadKey(true);
            
            source.Cancel();
            Console.WriteLine("Cancel requested...");            
            Task.WaitAll(tasks.ToArray());            

            Console.WriteLine("Done");            
        }

        public void ExecuteSampleQuery(SampleOptions options)
        {            
            var waitFor = string.Empty;
            if (options.SecondsQueryWillExecute >= 0) {
                waitFor = $"WAITFOR DELAY '00:00:{options.SecondsQueryWillExecute:00}';";
            }
            
            var query = $@"
                BEGIN TRAN; 
                    INSERT INTO dbo.TestResiliency (ThreadId) VALUES ({options.SampleId}); 
                    {waitFor}
                COMMIT TRAN; 
                SELECT @@SPID AS ServerProcessId, DATABASEPROPERTYEX(DB_NAME(DB_ID()), 'ServiceObjective') AS ServiceLevelObjective;";

            var csb = new SqlConnectionStringBuilder(_connectionString);
            Console.WriteLine($"[{options.SampleId:00}] Connecting to server: '{csb.DataSource}', database: '{csb.InitialCatalog}'");

            while (!options.Token.IsCancellationRequested)
            {
                int attempts = 0;
                int waitTime = 0;
                csb.ConnectTimeout = waitTime;

                var  conn = new SqlConnection(_connectionString);

                while (attempts < _maxAttempts)
                {
                    attempts += 1;
                    
                    try
                    {                        
                        if (options.SecondsConnectionStayOpen >= 0) {
                            if (options.Token.IsCancellationRequested) return;
                            conn.Open();
                            Task.Delay(options.SecondsConnectionStayOpen * 1000).Wait();                        
                        }
                        
                        var ei = conn.QuerySingle<ExecutionInfo>(                            
                            query, commandTimeout: waitTime
                            );

                        if (conn.State == ConnectionState.Open) conn.Close();
                        
                        if (options.SecondsBetweenQueries >= 0) {
                            if (options.Token.IsCancellationRequested) return;
                            Task.Delay(options.SecondsBetweenQueries * 1000).Wait();                       
                        }                         

                        Console.WriteLine($"[{options.SampleId:00}] {DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss")} > {ei}");
                        attempts = int.MaxValue;
                    }
                    catch (SqlException se)
                    {
                        if (_transientErrors.Contains(se.Number))
                        {
                            waitTime = attempts * _delay;

                            Console.WriteLine($"[{options.SampleId:00}] Transient error caught. Waiting {waitTime} seconds and then trying again...");
                            Console.WriteLine($"[{options.SampleId:00}] Error: [{se.Number}] {se.Message}");

                            Task.Delay(waitTime * 1000).Wait();
                        }
                        else
                        {
                            Console.WriteLine($"[{options.SampleId:00}] Unmanaged Error: [{se.Number}] {se.Message}");                            
                            throw;
                        }
                    }
                    catch (Exception e) {
                        Console.WriteLine($"[{options.SampleId:00}] Unhandled Exception: {e.Message}");
                        break;
                    }
                    finally
                    {
                        conn?.Close();
                    }
                }
            }
        }
    }
}
