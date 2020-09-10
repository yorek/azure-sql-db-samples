# Azure SQL Connection Resiliency in Python

This example show how to use the [tenacity](https://tenacity.readthedocs.io/en/latest/) library to implement a retry logic and make your connection to Azure SQL resilient.

Make sure to create a virtual environment (tests have been done using Python 3.7)

```
virtualenv env 
```

and activate it. Then install the required packages via

```
pip install -r Requirements.txt
```

Create a `.env` file starting from the provided template and add the connection string 

```
CONNECTION_STRING='DRIVER={ODBC Driver 17 for SQL Server};SERVER==*****.database.windows.net;DATABASE=resiliency_test;UID==*****;PWD=*****;Connect Timeout=30;'
```

to connect to the target Azure SQL database. You can then run the sample:

```
python ./retry.py -r
```

to run the test *WITH* resiliency and 

```
python ./retry.py -n 
```

to run the test *WITHOUT* resiliency.
The application will start an loop where it will run a query (whose execution time has been forced to be a couple of seconds). To simulate a disconnection, you may change the Service Level Objective, moving it from, for example `S0` to `S1`. You can use the `./sql/01-change-slo.sql` script to do that.

With a resilient connection, you will see some DEBUG information printed when the disconnection is detected, but the application will return to work normally as soon the database is available again. 

Without a resilient connection, as soon as the connection is broken, the application will crash.

## Additional Sample

A more complete and real-world sample is available here:

[Creating a REST API with Python and Azure SQL](https://github.com/Azure-Samples/azure-sql-db-python-rest-api/tree/master/)




