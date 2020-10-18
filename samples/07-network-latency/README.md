# 07 - Network Latency

Network latency can have a big impact in cloud applications: for this reason is strongly recommended to avoid creating chatty applications. A chatty application is an application that, instead of taking advatange of batching tecniques, sends to the database a command for each row on which it has to operate.

As a result this will generate a huge amount of small queries, each one with its own overhead and latency induced by network activity when doing the roundtrip to the database.

For example if you have to send 1000 rows to the database, a chatty application will execute 1000 inserts. If network latency is even just 1 msec, it means that the added overhead is one entire second.

It's much better to batch data and send 1 command working on the 1000 rows, so that the overhead will be paid only once per batch instead of once per each row.

In this samples several techniques to send a set of data are compared agains a chatty solution, so that you can see the difference in performances.

Make sure you have an empty database in Azure SQL and then create the needed database objects, by using the script in the `./dotnet/sql` folder. Create the `app.config` file starting from the provided template, and add the connection string for the database you will use in the test. Then, as usual, run `dotnet run` to run the app.

Here's some results after running the samples app in a Azure VM running in the same Azure Region of the target database:

TDB
