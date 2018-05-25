local IPPrefixDB=require'ipprefixdb'


-- create and open 
local db1 = IPPrefixDB.new()
db1:open("/tmp/ipdb.level")


-- store 

db1:put_cidr("192.168.0.0/16", "Entire 192 network private") 
db1:put_cidr("192.168.4.0/24",  "Video servers 192.168.4.0/24") 
db1:put_dotted_ip("192.168.4.18","192.168.4.22", "4.18 to 4.22 special ")

db1:put_ipv6_cidr("2001:550:c00::/38",6252001)
db1:put_ipv6_cidr("2001:470:b:c42::/63",1814991)
db1:put_ipv6_cidr("2001:978:2:39::5:800/117",2921044)
db1:put_ipv6_cidr("2001:2030:0:1c:6129:fc61:4a70:fc91/128",6252001)
db1:put_ipv6_cidr("2001:2030:0:1d:b986::/79",6255148)



db1:dump() 

print ("\n192.168.4.18=")
print (db1:get_dotted_ip("192.168.4.18") )

-- Test there are 3 nested  ranges  
print ("\n192.168.4.22=")
print (db1:get_dotted_ip("192.168.4.22") )  

print ("\n192.168.4.21=")
print (db1:get_dotted_ip("192.168.4.21") )  

print ("\n192.168.4.15=")
print (db1:get_dotted_ip("192.168.4.15") )

print ("\n192.168.4.23=")
print (db1:get_dotted_ip("192.168.4.23") )

print ("\n192.168.4.18=")
print (db1:get_dotted_ip("192.168.4.18") )

print ("\n192.168.4.17=")
print (db1:get_dotted_ip("192.168.4.17") )

print ("\n192.168.2.11=")
print (db1:get_dotted_ip("192.168.2.11") )

print ("\n192.168.5.11=")
print (db1:get_dotted_ip("192.168.5.11") )

print ("\n45.68.15.1=")
print (db1:get_dotted_ip("45.68.15.1") )

print ("\n241.168.200.199=")
print (db1:get_dotted_ip("\n241.168.200.199="))


-- dump
-- db1:dump()

-- closing 
db1:close()


