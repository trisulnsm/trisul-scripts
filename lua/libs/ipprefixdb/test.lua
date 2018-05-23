local IPPrefixDB=require'ipprefixdb'


-- create and open 
local db1 = IPPrefixDB.new()
db1:open("/tmp/ipdb.level")


-- store 

db1:put_cidr("192.168.0.0/16", "Entire 192 network private") 
db1:put_cidr("192.168.4.0/24",  "Video servers 192.168.4.0/24") 
db1:put_dotted_ip("192.168.4.18","192.168.4.22", "4.18 to 4.22 special ")

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


