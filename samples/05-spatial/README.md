# 04 - GeoSpatial Features Models

# GeoSpatial Support

Azure SQL offer extensive GeoSpatial support. Thanks to this support you can easily create solution that can manipulate and take advantage of this to offer geospatial capabilities in your applications without having to integrate external libraries or solution, and without having to deal with all the huge complexity of planar mapping, spheric coordinates, projects and stuff like that.

- [Spatial Data](https://docs.microsoft.com/en-us/sql/relational-databases/spatial/spatial-data-sql-server?view=azuresqldb-current)
- [Spatial Data Types Overview](https://docs.microsoft.com/en-us/sql/relational-databases/spatial/spatial-data-types-overview?view=azuresqldb-current)

As Azure SQL adheres to the Open Geospatial Consortium (OGS) standard, you can take the returned WKT result and copy and paste it in any solution compliant with OGS standard, for example [OpenLayers](https://openlayers.org/):

https://clydedacruz.github.io/openstreetmap-wkt-playground/

![Openlayers Playground](https://raw.githubusercontent.com/yorek/azure-sql-db-samples/master/samples/05-spatial/openlayers-playground.png)

Transit scheduling, geographic, and real-time data provided by permission of King County
[King County Metro Developer Resources](https://kingcounty.gov/depts/transportation/metro/travel-options/bus/app-center/developer-resources.aspx)
