# 03 - Azure SQL JSON Support

Azure SQL provide extensive support to JSON. Full details can be found in [JSON Data](https://docs.microsoft.com/en-us/sql/relational-databases/json/json-data-sql-server) document.

This repo contains what is needed to get a kickstart to use JSON on Azure SQL. The Jupyter Notebook will guide you through:

- **Query JSON**: Learn how to query and extract data from a JSON document

- **Modify JSON**: Azure SQL allows not only to read a JSON but also to modify it

- **Create JSON**: If have data saved in tables, but as a developer you'd love to turn it into JSON to easily consume it from your application. Azure SQL make this operation really easy.

- **Index JSON**: If you are planning to query JSON data frequently it will be a good choice to add some index to support the most common queries 

If you're new to Jupyter Notebooks, please read the repo [README](../README.md) to learn how to use them.

The aforementioned samples needs some tables and data to be used, so make sure you setup the environment by executing the script `00-setup-samples.sql` in the database of your choice. If you are new to the platform and need help on creating a new database, please refer again to the [README](../README.md) in the root folder.

The `sample.json` file is not used in the sample, but it is useful to take a look at the kind of JSON document the samples will be working on.
## Taking advantage of JSON for developing modern applications

JSON can really make the exchange of data between applications and database really easy and flexible. The following link give you additional resources that you can use to learn how to take advantage of JSON support in Azure SQL:

- [REST API using JSON, Dapper and Azure SQL](https://github.com/Azure-Samples/azure-sql-db-dotnet-rest-api)
- [Using Azure SQL Change Tracking API to Sync partially connected Apps](https://github.com/Azure-Samples/azure-sql-db-sync-api-change-tracking)
- [REST API using Azure SQL, JSON, Flask and Python](https://github.com/Azure-Samples/azure-sql-db-python-rest-api)
- [One-To-Many Mapping with Dapper and JSON](https://medium.com/dapper-net/one-to-many-mapping-with-dapper-55ae6a65cfd4)
- [Work with JSON files with Azure SQL](https://medium.com/@mauridb/work-with-json-files-with-azure-sql-8946f066ddd4)