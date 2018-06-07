

Prep : Create a new context in which you can play 
====================================================

	
````

trisulctl_probe create context test1 


````

Now add in the helper macros 



Step 1:  How to hook into Trisul Resources
=================

````

DOCKER:localhost:root$ trisulctl_probe  testbench run /trisulroot/upload_misc.tcpd 
..
Replacing image with 
/usr/local/bin/trisul  -nodemon /usr/local/etc/trisul-probe/domain0/probe0/context_debug0/trisulProbeConfig.xml -mode offline -in /trisulroot/upload_misc.tcpd

GET toolbar.google.com /buttons/feeds/topbuttons/?hl=en&sd=com HTTP/1.1
GET www.google.com /tools/toolbar/service/version4?&version=4.0.1601.4978&os=big&hl=en&tbbrand=GGLD&sd=com&osver=5.1&ossp=2.0&browser=6.0.2900.2180&rlz=&needc=3 HTTP/1.1
GET www.google.com /url?sa=p&pref=tb&pval=2&q=http%3A%2F%2Fwww.google.com%2Ftools%2Ftoolbar%2Fservice%2Fnoupdate%3F HTTP/1.1
GET www.google.com /tools/toolbar/service/noupdate? HTTP/1.1
GET www.dnswatch.info / HTTP/1.1
GET www.dnswatch.info /js/lookup.js HTTP/1.1
GET pagead2.googlesyndication.com /pagead/show_ads.js HTTP/1.1
GET www.dnswatch.info /images/dnswatch-logo.gif HTTP/1.1


````



Step 2:  Generate an alert and push it into Trisul 



---



Step 3 : How to read in an CSV Intel file 

Download helper csv.lua 
Load  URL -> full line map in memory table  





