local ipdb=require'ipprefixdb' 

if #arg ~= 3 then
	print("Usage : querytool  leveldb-database type ip-address")
	return  
end

local db1=ipdb:new()
db1:open(arg[1],true) 


db1:set_databasename(arg[2])

print("for ip ".. arg[3])
print(db1:get_dotted_ip(arg[3]))



db1:close()


