GeoDB - compilers for various Geo Databases
===========================================

These compilers convert IP subnet to Geo mappings from a CSV format into a LevelDB backend.  

> *Purpose* You could use the API's that come with these databases.  Those who desire a common format for storing IP Subnet information will find this useful. 


The following compilers are available
----------------

1.  `compile_geolite2` : MaxMind GeoLite2 from  https://dev.maxmind.com/geoip/geoip2/geolite2/
2.  `compile_ip2location` : IP2Location LITE : from  https://lite.ip2location.com/  

## Running the compilers

Here are some rules

1. All CSV files must be UNZIPped 
2. Put all the CSV files in a single directory 

### IP2Location   

To compile the IP2Location lists  in directory `ip2loc` into a LevelDB prefix database `ip2loc.level`

````lua
luajit compile_ip2loc.lua /home/demo/directory/with/IP2Location/CSV/Files  ip2loc.level 
````

### GeoLite2 

To compile the GeoLite2  lists  in directory `geolite2` into a LevelDB prefix database `ip2loc.level`

````lua
luajit compile_ip2loc.lua /home/demo/directory/with/IP2Location/CSV/Files  ip2loc.level 
````


## Testing

In the `helpers` directory here, you can find a `querytool.lua` that you can use to check any IP in any of the databases

`Usage : querytool <leveldb-directory> <geo-type>  <ip-address>`


Showing ASN query 

````bash

cd helpers 
luajit querytool.lua ../my.level ASN 45.118.180.88

````
Showing query for CITYCODE 

````bash
luajit querytool.lua ../my.level CITYCODE 4143637
CITYCODE
By  Raw 4143637
ZZZZ4143637	US_DE_Middletown
````

