using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;
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
            var sample = new IdleResilientConnectionSample();
            sample.RunSample(CONNECTION_STRING);              
        }
    }
}
