# geoflows -  use a Geo database to track flow activity

This script uses the libftrie.so from the [ftrie](https://github.com/trisulnsm/ftrie) project to track the number of active flows per country and city.


## shared library  libftrie.so 

File libfrie.so is Ubuntu 16.04 , you can build the ftrie project for your own platform
Copy `libftrie.so` file to the lib directory. 

```lua
cp libftrie.so /usr/local/lib/trisul-probe/
````


