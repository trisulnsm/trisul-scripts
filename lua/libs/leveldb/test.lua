
-- version: %VERSION%
local LDB=require'tris_leveldb'


-- create and open 
local db1 = LDB.new()
db1:open("/tmp/mytest1.level")

-- put a few keys 
db1:put("k1","veeraTheDog")
db1:put("k2","Pakdam")
db1:put("k10.0.0.1","Pakdam")
db1:put("k10.0.0.22","Pakdam")
db1:put("k1","veeraTheDogOverWrite")
db1:put("Longerkey with spaces ","Pakdam Pakdai")
db1:put("k100","ChottaBheem")

-- put a few keys at once (atomic) 
-- use a table underlying will use LevelDB WriteBatch 
db1:put_table( {
	k1   = "valu1",
	key2 = "value2",
	kkk5 = 10002,
	["What is this long key"] = "long key value"
} )

-- get 
print(db1:get("k1"))
print(db1:get("k2"))
print(db1:get("k100"))
print(db1:get("k33notexist"))


-- dump  full database 
-- demonstrates how to iterate 
local iter=db1:create_iterator()
iter:seek_to_first()
while iter:valid() do 
	local k,v = iter:key_value()
	print(k.."="..v)
	iter:iter_next()
end 
iter:destroy()



-- delete and then dump the database 
db1:delete("k100")
local iter=db1:create_iterator()
iter:seek_to_first()
while iter:valid() do 
	local k,v = iter:key_value()
	print(k.."="..v)
	iter:iter_next()
end 
iter:destroy()


-- test seekto  
-- used to get upper_bound match 
print("Test. seek_to()")
local iter=db1:create_iterator()
iter:seek_to("k10.0.0.12")
local k,v = iter:key_value()
if k and v  then print(k.."="..v) end
print('next')
iter:iter_next()
local k,v = iter:key_value()
if k and v  then print(k.."="..v) end
iter:destroy()

-- test seekto as above and then  prev()
-- to find the lower_bound()  
print("Test -- PREV")
local iter=db1:create_iterator()
iter:seek_to("k10.0.0.12")
local k,v = iter:key_value()
if k and v  then print(k.."="..v) end
print('prev')
iter:iter_prev()
local k,v = iter:key_value()
if k and v  then print(k.."="..v) end
iter:destroy()

-- close 
print("Closing")
db1:close() 


-- dump a level db ,using the built in method 
db1:open("/tmp/mytest1.level")
db1:dump()

-- upper search , easier to use than seek_to() and value() 
-- 
local iter=db1:create_iterator()
local k,v = db1:upper(iter,"05.6E.20.00")
if k then 
	print(k.."="..v)
end 

iter:destroy() -- remember to do this with iterators you create 

db1:close() 



-- test put Table
db1:open("/tmp/mytest1.level")


db1:dump()

db1:close() 



