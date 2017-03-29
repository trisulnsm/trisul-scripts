-- test1.lua
-- Test the level db interface


local LevelDB=require'helpers/tris_leveldb'


local l_writer, l_reader, l_closer, l_deleter  = LevelDB.from_addr( LevelDB.open("Test111.ldb") )

l_writer("k1", " fooo")
l_writer("k2", " baaarr")
l_writer("192.168.2.79", " key is ubuntu64 test")


local val

val = l_reader("k1")
print("k1 value is " .. val)

val= l_reader("farbaz")
if val then
print("farbaz value is " .. val)
else
print("farbaz value is nil")
end


l_writer("gmail.com", "72.203.203.11")
val = l_reader("gmail.com")
print("gmail.com value is " .. val)


local ret,err= l_deleter("gmail.com")
if ret then 
print("Deleted key")
else
print("Err deleting ".. err)
end


val = l_reader("gmail.com")
if val then 
print("gmail.com value is " .. val)
else
print("gmail.com value is NIL " )
end 

ret,err= l_deleter("gmail.com")
if ret then 
print("Deleted key")
else
print("Err deleting ".. err)
end



l_closer() 


-- dump the DB 
print("DB Contents-----")
LevelDB.dump("Test111.ldb")


