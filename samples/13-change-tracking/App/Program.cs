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

var syncSetup = new SyncSetup(new string[] { "TrainingSessions" });

var agent = new SyncAgent(localProvider, remoteProvider);

Console.WriteLine("Sync Started.");
do
{
    var s1 = await agent.SynchronizeAsync(syncSetup);

    Console.WriteLine(s1);

} while (Console.ReadKey().Key != ConsoleKey.Escape);

Console.WriteLine("End");