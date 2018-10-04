# Trisul Unix Socket API

Allows external programs to insert metrics into the Trisul pipeline. 
You write [Trisul Engine:API](https://www.trisul.org/docs/lua/obj_engine.html)  commands in a new-line separated format into a Unix Socket 

The lowest resolution with this method is  1-second. 

## How to use 

When you [install](https://www.trisul.org/docs/lua/basics.html#installing_and_uninstalling) this script and restart Trisul-Probe you will find that it has created a new Unix Socket under

```
/usr/local/var/lib/trisul-probe/domain0/probe0/context0/run/api.sock.0 
```

You can simply write commands to that socket with the following text syntax. Each parameter is separated by a "\n"

````
commandname<\n>
argument1<\n>
argument2<\n>
````

For example: to update a counter  write this string. Note that 

````
update_counter
{4DF11F00-B726-4260-5F83-0D9891197B45}
192.168.29.8
0
10023
````



