# 07 - Network Latency

Network latency can have a big impact in cloud applications: for this reason is strongly recommended to avoid creating chatty applications. A chatty application is an application that, instead of taking advatange of batching tecniques, sends to the database a command for each row on which it has to operate.

As a result this will generate a huge amount of small queries, each one with its own overhead and latency induced by network activity when doing the roundtrip to the database.

For example if you have to send 1000 rows to the database, a chatty application will execute 1000 inserts. If network latency is even just 1 msec, it means that the added overhead is one entire second.

It's much better to batch data and send 1 command working on the 1000 rows, so that the overhead will be paid only once per batch instead of once per each row.

In this samples several techniques to send a set of data are compared agains a chatty solution, so that you can see the difference in performances.

Make sure you have an empty database in Azure SQL and then create the needed database objects, by using the script in the `./dotnet/sql` folder. Create the `app.config` file starting from the provided template, and add the connection string for the database you will use in the test. Then, as usual, run `dotnet run` to run the app.

Here's some results after running the samples app in a Azure VM running in the same Azure Region of the target database, loading 1000 rows to Azure SQL using BC_Gen5_2 service objective:

|Test Type|Elapsed Time|Rows/Sec|
|---|---|---|
|*Multiple Batches* (*)| 2.158 secs | 463 rows/sec |
|*Single Batch* (**)|1.649 secs| 606 rows/sec |
|*TVP*|0.071 secs| 14084 rows/sec | 
|*JSON*|0.179 secs| 6060 rows/sec |
|*Row Constructors*|0.376 secs| 2659 rows/sec |
|*BulkCopy*|0.071 secs| 14084 rows/sec |

And when loading 10000 rows:

|Test Type|Elapsed Time|Rows/Sec|
|---|---|---|
|*Multiple Batches* (*)| 17.56 secs | 569 rows/sec |
|*Single Batch* (**)| 16.51 secs| 605 rows/sec |
|*TVP*|0.275 secs| 36363 rows/sec | 
|*JSON*|0.65 secs| 15384 rows/sec |
|*Row Constructors*|3.734 secs| 2677 rows/sec |
|*BulkCopy*|0.197 secs| 50761 rows/sec |

And if you are running test from On-Premises instead, performance gap is way bigger (just using 1000 rows):

|Test Type|Elapsed Time|Rows/Sec|
|---|---|---|
|*Multiple Batches* (*)| 25.305 secs | 39 rows/sec |
|*Single Batch* (**)| 24.752 secs| 40 rows/sec |
|*TVP*|0.96 secs| 1041 rows/sec | 
|*JSON*|1.554 secs| 643 rows/sec |
|*Row Constructors*|0.815 secs| 1226 rows/sec |
|*BulkCopy*|0.43 secs| 2325 rows/sec |

Where:

(*): One INSERT per each row, each one in its own batch

(**): Sending one INSERT per each row but as a single batch