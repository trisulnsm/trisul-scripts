HTTP Server 
-----------

This plugin demonstrates the use of a flow based counter. 
We tap into the HTTP-Header messages, then pull out the HTTP Server attribute 
and then meter based on the web server (apache/nginx..) etc.

The example is purposely long winded, we extract the entire HTTP header into a LUA table. This is to demonstrate the techniques. You can also directly write a regex to only pull out the HTTP Server attribute.




