silk.lua
========

Import silk data dumps into Trisul for further analysis 


Make sure you enable `--pack-interfaces` for maximum benefit

````
root@devbox-Inspiron-3442:~# /usr/local/sbin/rwflowpack '--pack-interfaces' '--sensor-configuration=/data/sensor.conf' '--compression-method=best' '--site-config-file=/data/silk.conf' '--archive-directory=/usr/local/var/lib/rwflowpack/archive' '--output-mode=local-storage' '--root-directory=/data' '--pidfile=/usr/local/var/lib/rwflowpack/log/rwflowpack.pid' '--log-level=debug' '--log-destination=syslog' '--no-daemon'
````

