# 06 - Azure SQL Key-Value Sample

There are no specific features for create a key-value store solution, as Memory-Optimized Tables can be used very efficiently for this kind of workload.
Memory-Optimized tables can be configured to be Durable or Non-Durable. In the latter case data is never persisted and they really behave like an in-memory cache. Here's some useful links:
- [In-Memory OLTP in Azure SQL Database](https://azure.microsoft.com/en-us/blog/in-memory-oltp-in-azure-sql-database/)
- [Transact-SQL Support for In-Memory OLTP](https://docs.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/transact-sql-support-for-in-memory-oltp)
- [Optimize performance by using in-memory technologies](https://docs.microsoft.com/en-us/azure/azure-sql/in-memory-oltp-overview)

This repo contains what is needed to get a kickstart to implement a Key-Value store Azure SQL. The [Jupyter Notebook](./key-value.ipynb) contains the basic idea with some additional explanations and also with performance tests results. The [SQL file](./key-value.sql) contains everything neede to create the sample and run the test on your own.
