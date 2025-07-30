using System;
using DotNetEnv;

namespace AzureSQL.DevelopmentBestPractices
{
    class Program
    {
        static void Main(string[] args)
        {
            Env.Load();

            var sample = new NetworkLatencySample(Environment.GetEnvironmentVariable("MSSQL"));
            sample.RunSample();              
        }
    }
}
