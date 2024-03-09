using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.Data.SqlClient;
using System.Threading;
using System.Threading.Tasks;
using Dapper;
using Polly;
using System.ComponentModel;

namespace AzureSQL.DevelopmentBestPractices
{
    class ExecutionInfo
    {
        public int ServerProcessId = 0;
        public string ServiceLevelObjective = string.Empty;
        public string ServerName = string.Empty;

        public override string ToString()
        {
            return $"SERVER: {ServerName}, SLO: {ServiceLevelObjective}, SPID: {ServerProcessId}";
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

    class ResilientConnectionSample(string connectionString)
    {
        // Error list created from: 
        // - https://github.com/dotnet/efcore/blob/main/src/EFCore.SqlServer/Storage/Internal/SqlServerTransientExceptionDetector.cs
        // - https://docs.microsoft.com/en-us/dotnet/api/microsoft.data.sqlclient.sqlconfigurableretryfactory?view=sqlclient-dotnet-standard-4.1
        // - https://docs.microsoft.com/en-us/azure/sql-database/sql-database-develop-error-messages
        // Manually added also
        // 0, 18456
        private static readonly List<int> _transientErrors = [
            233, 997, 921, 669, 617, 601, 121, 64, 20, 0, 53, 258,
            1203, 1204, 1205, 1222, 1221,
            1807,
            3906, // Database in readonly mode during failover
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
        ];

        private readonly string _connectionString = connectionString;

        public void RunSample()
        {
            var source = new CancellationTokenSource();
            var token = source.Token;

            var tests = new List<SampleOptions>
            {
                new()
                {
                    SampleId = 1,
                    SecondsBetweenQueries = 2,
                    SecondsConnectionStayOpen = 0,
                    SecondsQueryWillExecute = 0,
                    Token = token
                },
                new()
                {
                    SampleId = 2,
                    SecondsBetweenQueries = 0,
                    SecondsConnectionStayOpen = 2,
                    SecondsQueryWillExecute = 0,
                    Token = token
                },
                new()
                {
                    SampleId = 3,
                    SecondsBetweenQueries = 0,
                    SecondsConnectionStayOpen = 0,
                    SecondsQueryWillExecute = 2,
                    Token = token
                }
            };

            var tasks = new List<Task>();
            foreach (var t in tests)
            {
                tasks.Add(Task.Run(() => ExecuteSampleQuery(t)));
            }

            Console.WriteLine("Press CTRL+C to terminate the application...");
            Console.CancelKeyPress += (object sender, ConsoleCancelEventArgs args) => {
                if (!source.IsCancellationRequested)
                {
                    args.Cancel = true;
                    source.Cancel();
                    Console.WriteLine("Cancel requested...waiting for threads to terminate. Hit CTRL+C again to terminate immediately.");
                } else {
                    Console.WriteLine("Terminating all threads...");                    
                }
            };

            try
            {
                Task.WaitAll([.. tasks]);
            } catch (AggregateException ae)
            {
                foreach(var e in ae.InnerExceptions)
                {
                    Console.WriteLine(e.Message);
                }
            }
            Console.WriteLine("Done");
        }

        public void ExecuteSampleQuery(SampleOptions options)
        {
            var p = Policy
                .Handle<SqlException>(CheckIfTransientError)
                .Or<TimeoutException>()
                .OrInner<Win32Exception>(CheckIfTransientError)
                .WaitAndRetry(5, retryAttempt => TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)),
                    (exception, timeSpan, retryCount, context) =>
                    {
                        var details = string.Empty;
                        if (exception is SqlException) {
                            var sx = exception as SqlException;
                            details = $" [SQL Error: {sx.Number}]";
                        }
                        Console.WriteLine($"[{options.SampleId:00}] Retry called {retryCount} times, next retry in: {timeSpan}). Reason: {exception.GetType().Name}{details}: {exception.Message}");
                    });

            void Log(string message) {
                Console.WriteLine($"[{options.SampleId:00}] {DateTime.Now:yyyy-MM-dd HH:mm:ss} > {message}");
            }

            var waitFor = string.Empty;
            if (options.SecondsQueryWillExecute >= 0)
            {
                waitFor = $"WAITFOR DELAY '00:00:{options.SecondsQueryWillExecute:00}';";
            }

            var query = $@"
                BEGIN TRAN; 
                    INSERT INTO dbo.TestResiliency (ThreadId) VALUES ({options.SampleId}); 
                    {waitFor}
                COMMIT TRAN; 
                SELECT @@SPID AS ServerProcessId, DATABASEPROPERTYEX(DB_NAME(DB_ID()), 'ServiceObjective') AS ServiceLevelObjective, @@SERVERNAME as ServerName;";

            var csb = new SqlConnectionStringBuilder(_connectionString);
            Log($"Connecting to server: '{csb.DataSource}', database: '{csb.InitialCatalog}'");

            while (!options.Token.IsCancellationRequested)
            {
                p.Execute(() =>{
                    using var conn = new SqlConnection(_connectionString);

                    if (options.Token.IsCancellationRequested) return;

                    if (options.SecondsConnectionStayOpen >= 0)
                    {
                        conn.Open();
                        Task.Delay(options.SecondsConnectionStayOpen * 1000).Wait(options.Token);
                    }

                    if (options.Token.IsCancellationRequested) return;

                    var ei = conn.QuerySingle<ExecutionInfo>(query);

                    if (conn.State == ConnectionState.Open) conn.Close();

                    if (options.Token.IsCancellationRequested) return;

                    if (options.SecondsBetweenQueries >= 0)
                    {
                        Task.Delay(options.SecondsBetweenQueries * 1000).Wait(options.Token);
                    }

                    if (options.Token.IsCancellationRequested) return;

                    Log(ei.ToString());
                });
            }
        }
    
        private bool CheckIfTransientError(Exception ex)
        {
            if (ex is SqlException sqlException)
            {
                foreach (SqlError err in sqlException.Errors)
                {
                    if (_transientErrors.Contains(err.Number)) return true;
                }

                return false;
            }

            return ex is TimeoutException;
        }
    }

}
