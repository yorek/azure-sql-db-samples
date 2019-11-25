using System;
using System.IO;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Configuration.Json;
using Microsoft.Extensions.DependencyInjection;

namespace AzureSQL.DevelopmentBestPractices
{
    class Program
    {
        static readonly string CONNECTION_STRING = "";

        static Program()
        {
            var config = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("app.config.json", optional: false, reloadOnChange: false)                
                .Build();                 

            CONNECTION_STRING = config["connection-string"];
        }

        static void Main(string[] args)
        {
            var sample = new ResilientConnectionSample(CONNECTION_STRING);
            sample.RunSample();              
        }
    }
}
