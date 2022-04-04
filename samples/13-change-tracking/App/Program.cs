using Dotmim.Sync;
using Dotmim.Sync.Sqlite;
using Dotmim.Sync.SqlServer;

DotNetEnv.Env.Load();

Console.WriteLine("Setting up...");

string azureConnectionString = DotNetEnv.Env.GetString("AZURE_CONNECTION_STRING");
if (string.IsNullOrEmpty(azureConnectionString)) {
    Console.WriteLine("Environment variable AZURE_CONNECTION_STRING not found.");
    return;
}

var remoteProvider = new SqlSyncChangeTrackingProvider(azureConnectionString);
var localProvider = new SqliteSyncProvider("training-sessions.db");

var tables = new string[] {"TrainingSessions"};

var agent = new SyncAgent(localProvider, remoteProvider, tables);

Console.WriteLine("Sync Started.");
do
{
    var s1 = await agent.SynchronizeAsync();

    Console.WriteLine(s1);

} while (Console.ReadKey().Key != ConsoleKey.Escape);

Console.WriteLine("End");