using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.Data.SqlClient;
using System.Threading;
using System.Threading.Tasks;
using System.Diagnostics;
using Dapper;
using Bogus;
using Newtonsoft.Json;
using System.Linq;
using FastMember;

namespace AzureSQL.DevelopmentBestPractices
{
    public class Customer
    {
        public int CustomerID { get; set; }
        public string Title { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string MiddleName { get; set; }
        public string CompanyName { get; set; }
        public string SalesPerson { get; set; }
        public string EmailAddress { get; set; }
        public string Phone { get; set; }
        public DateTime ModifiedDate { get; set; }
    }

    public static class Utility
    {
        public static string SetMaxLength(this string source, int length)
        {
            int l = Math.Min(source.Length, length);
            return source.Substring(0, l);
        }

        public static string EscapeQuote(this string source)
        {
            return source.Replace("'", "''");
        }

    }

    public class NetworkLatencySample
    {
        private string _connectionString = "";
        private const int CUSTOMERS_COUNT = 1000;

        public NetworkLatencySample(string connectionString)
        {
            _connectionString = connectionString;
        }

        public void RunSample()
        {
            var customers = GenerateCustomers();

            Console.WriteLine($"Network Latency Impact Test: Running {CUSTOMERS_COUNT} INSERT");
            Console.WriteLine();

            var sw = new Stopwatch();

            Action<Action<List<Customer>>, string> RunTest = (Test, message) => {
                Console.WriteLine(message);
                sw.Restart();
                Test(customers);
                sw.Stop();
                Console.WriteLine($"Elapsed: {sw.ElapsedMilliseconds / 1000.0} secs");
                Console.WriteLine();
            };

            RunTest(BasicSample, "Running *MULTIPLE BATCHES* sample");

            RunTest(DapperSample, "Running *SINGLE-BATCH-LOOKALIKE* sample");

            RunTest(TVPSample, "Running *TVP* sample");

            RunTest(JsonSample, "Running *JSON* sample");

            RunTest(RowConstructorsSample, "Running *Row Constructors* sample");

            RunTest(BulkCopySample, "Running *BulkCopy* sample");

            Console.WriteLine("Done.");
        }

        void BasicSample(List<Customer> customers)
        {
            using (var conn = new SqlConnection(_connectionString))
            {
                conn.Execute("TRUNCATE TABLE dbo.NetworkLatencyTestCustomers");

                conn.Open();
                foreach (var c in customers)
                {
                    conn.Execute("dbo.InsertNetworkLatencyTestCustomers_Basic", c, commandType: CommandType.StoredProcedure);
                }
                conn.Close();
            }
        }

        void DapperSample(List<Customer> customers)
        {
            using (var conn = new SqlConnection(_connectionString))
            {
                conn.Execute("TRUNCATE TABLE dbo.NetworkLatencyTestCustomers");

                conn.Execute("dbo.InsertNetworkLatencyTestCustomers_Basic", customers, commandType: CommandType.StoredProcedure);
            }
        }

        void TVPSample(List<Customer> customers)
        {
            var ct = CustomersToDataTable(customers);

            using (var conn = new SqlConnection(_connectionString))
            {
                conn.Execute("TRUNCATE TABLE dbo.NetworkLatencyTestCustomers");

                conn.Execute("dbo.InsertNetworkLatencyTestCustomers_TVP", new { @c = ct.AsTableValuedParameter("CustomerType") }, commandType: CommandType.StoredProcedure);
            }
        }

        void JsonSample(List<Customer> customers)
        {
            using (var conn = new SqlConnection(_connectionString))
            {
                conn.Execute("TRUNCATE TABLE dbo.NetworkLatencyTestCustomers");

                var json = JsonConvert.SerializeObject(customers);

                conn.Execute("dbo.InsertNetworkLatencyTestCustomers_JSON", new { @json = json }, commandType: CommandType.StoredProcedure);
            }
        }

        void RowConstructorsSample(List<Customer> customers)
        {            
            int s = 0;
            int b = 1000;
            if (b > customers.Count) b = customers.Count;

            while (s < customers.Count)
            {
                var payload = customers.GetRange(s, b).Select(c => { return $"({c.CustomerID}, '{c.Title.EscapeQuote()}', '{c.FirstName.EscapeQuote()}', '{c.LastName.EscapeQuote()}', '{c.MiddleName.EscapeQuote()}', '{c.CompanyName.EscapeQuote()}', '{c.SalesPerson.EscapeQuote()}', '{c.EmailAddress.EscapeQuote()}', '{c.Phone.EscapeQuote()}', '{c.ModifiedDate.ToString("o")}')";});

                using (var conn = new SqlConnection(_connectionString))
                {
                    conn.Execute("TRUNCATE TABLE dbo.NetworkLatencyTestCustomers");

                    conn.Execute($"INSERT INTO [dbo].[NetworkLatencyTestCustomers] ([CustomerID], [Title], [FirstName], [LastName], [MiddleName], [CompanyName], [SalesPerson], [EmailAddress], [Phone], [ModifiedDate]) VALUES {string.Join(',', payload)}", commandType: CommandType.Text);
                }

                s += b;
                if ((s + b) > customers.Count) b = customers.Count - s;
            }
        }

        void BulkCopySample(List<Customer> customers)
        {
            var ct = CustomersToDataTable(customers);

            using(var conn = new SqlConnection(_connectionString))
            {
                conn.Execute("TRUNCATE TABLE dbo.NetworkLatencyTestCustomers");

                conn.Open();
                using(var bc = new SqlBulkCopy(conn))                
                {
                    bc.DestinationTableName = "dbo.NetworkLatencyTestCustomers";
                    bc.WriteToServer(ct);
                }
            }
        }

        public List<Customer> GenerateCustomers()
        {
            var userFaker = new Faker<Customer>()
                .RuleFor(c => c.CustomerID, f => f.IndexFaker)
                .RuleFor(c => c.Title, f => f.Name.Prefix(f.Person.Gender).SetMaxLength(200))
                .RuleFor(c => c.FirstName, f => f.Name.FirstName().SetMaxLength(200))
                .RuleFor(c => c.LastName, f => f.Name.LastName().SetMaxLength(200))
                .RuleFor(c => c.MiddleName, f => f.Name.FirstName().SetMaxLength(200))
                .RuleFor(c => c.CompanyName, f => f.Company.CompanyName().SetMaxLength(200))
                .RuleFor(c => c.SalesPerson, f => f.Name.FullName().SetMaxLength(200))
                .RuleFor(c => c.Phone, f => f.Person.Phone.SetMaxLength(20))
                .RuleFor(c => c.EmailAddress, (f, u) => f.Internet.Email(u.FirstName, u.LastName).SetMaxLength(1024))
                .RuleFor(c => c.ModifiedDate, f => f.Date.Recent(100));

            var result = userFaker.Generate(CUSTOMERS_COUNT);

            return result;
        }

        public DataTable CustomersToDataTable(List<Customer> customers)
        {
            var ct = new DataTable("CustomerType");
            var r = ObjectReader.Create(customers, 
                "CustomerID", 
                "Title", 
                "FirstName", 
                "LastName", 
                "MiddleName", 
                "CompanyName", 
                "SalesPerson", 
                "EmailAddress", 
                "Phone", 
                "ModifiedDate"
            );
            ct.Load(r);
            return ct;
        }
    }
}
