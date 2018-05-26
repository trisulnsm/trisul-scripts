local ipdb=require'ipprefixdb' 

if #arg ==2 then
	dbpath = arg[1]
	dbname = nil  
	ipaddr = arg[2]
elseif #arg ==3  then
	dbpath = arg[1]
	dbname = arg[2]
	ipaddr = arg[3]

else
	print("Usage : querytool  leveldb-database type ip-address")
	return  
end

local db1=ipdb:new()
db1:open(dbpath,true) 

print(dbname) 
if dbname then 
	db1:set_databasename(dbname)
end 


print("For IP ".. ipaddr)
print(db1:get_dotted_ip(ipaddr))

db1:close()


