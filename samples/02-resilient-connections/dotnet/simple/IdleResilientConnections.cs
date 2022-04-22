using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.Data.SqlClient;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Configuration.Json;
using Microsoft.Extensions.DependencyInjection;

namespace AzureSQL.DevelopmentBestPractices
{
    class IdleResilientConnectionSample
    {     
        private string _connectionString = "";
      
        public void RunSample(string connectionString)
        {
            Console.WriteLine("Testing Idle Connection Resiliency");
            _connectionString = connectionString;

            var csb = new SqlConnectionStringBuilder(connectionString);
            Console.WriteLine();
            Console.WriteLine($"Data Source: {csb.DataSource}");
            Console.WriteLine($"Initial Catalog: {csb.InitialCatalog}");
            Console.WriteLine();

            Console.WriteLine("----- TEST 1: CONNECTION RESILIENCY TURNED *ON*");
            csb.ConnectRetryCount = 5;
            csb.ConnectRetryInterval = 15;
            csb.ConnectTimeout = (csb.ConnectRetryCount * csb.ConnectRetryInterval);
            Console.WriteLine($"ConnectRetryCount: {csb.ConnectRetryCount}");
            Console.WriteLine($"ConnectRetryInterval: {csb.ConnectRetryInterval}");
            RunSimpleTest(csb.ToString());
            
            Console.WriteLine();
            Console.WriteLine("Hit 'Enter' to run next test.");
            Console.ReadLine();     

            Console.WriteLine("----- TEST 2: CONNECTION RESILIENCY TURNED *OFF*");
            csb.ConnectRetryCount = 0;    
            Console.WriteLine($"ConnectRetryCount: {csb.ConnectRetryCount}");
            Console.WriteLine($"ConnectRetryInterval: {csb.ConnectRetryInterval}");                    
            RunSimpleTest(csb.ToString());
              
            Console.WriteLine();
            Console.WriteLine("Hit 'Enter' to terminate sample.");
            Console.ReadLine();                 
        }

        private void RunSimpleTest(string localConnectionString)
        {
            SqlConnection conn = null;
            try {
                conn = new SqlConnection(localConnectionString);
            
                conn.Open();
                Console.WriteLine($"Connection is now *{conn.State}*");
                
                var spid1 = GetSPID(conn);
                Console.WriteLine($"Current SPID is: {spid1}.");           

                Console.WriteLine("Hit [K] to kill the connection (a new thread will be spawned to execute the selected action).");                
                var c = string.Empty;
                while (!(new string[] {"k"}).Contains(c))  {
                    c = Console.ReadKey(intercept: true).KeyChar.ToString().ToLower();                    
                }
            
                Console.WriteLine("Killing session...");
                Task.Run(() => { KillSPID(spid1); }).Wait();             
                Console.WriteLine("Session killed...");
                Console.WriteLine();

                Console.WriteLine("Trying to execute a command after connection has been killed...");
                
                var spid2 = GetSPID(conn);                
                Console.WriteLine($"Still here. Current SPID is: {spid2}.");       
            } 
            catch (Exception ex) {
                var cx = ex;
                while (cx != null)
                {
                    if (cx is SqlException) {
                        var sx = cx as SqlException;
                        Console.WriteLine($"[{sx.GetType().Name}][SQL Error: {sx.Number}] " +  sx.Message);
                    } else  {
                        Console.WriteLine($"[{cx.GetType().Name}] " + cx.Message);
                    }                    
                    cx = cx.InnerException;
                }
            } 
            finally {            
                conn.Close();
            }         
        }      

        private int GetSPID(SqlConnection conn)
        {
            var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT @@SPID";
            cmd.CommandTimeout = 0;
            var spid = int.Parse(cmd.ExecuteScalar().ToString());
            return spid;
        }

        private void KillSPID(int spid)
        {
            var sb = new SqlConnectionStringBuilder(_connectionString);
            sb.ApplicationName = "ConnectionKiller";

            using(var conn = new SqlConnection(sb.ToString()))
            {
                conn.Open();

                var cmd = conn.CreateCommand();
                cmd.CommandText = $"KILL {spid}";
                
                cmd.ExecuteNonQuery();

                conn.Close();
            }    
        }      
    }
}
