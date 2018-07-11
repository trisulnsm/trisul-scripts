-- compiles a Critical-Stack intel data file
-- created for Bro-IDS into a LevelDB database suitable for TrisulNSM 

local LDB=require'tris_leveldb' 

if #arg ~= 2 then
	print("Usage : luajit compile_cs.lua  master-publc.bro.dat  critical-stack.trisul.0")
	return  
end

local  input_file = arg[1]
local  output_leveldb  = arg[2]

-- open dn 
local db1 = LDB.new()
db1:open(output_leveldb)

-- Process each line 
print("Processing ".. input_file)
local nitems=0
local f = io.open(input_file)
for line  in f:lines() do
	if line:find("%s*#$") == nil then 
		local _,_,k = line:find("(%S+)")
		db1:put(k, line:gsub("\t"," ") ) 
		nitems = nitems + 1
	end 
end

db1:close()

print("Compiled "..nitems.." indicators into output database ".. output_leveldb)

