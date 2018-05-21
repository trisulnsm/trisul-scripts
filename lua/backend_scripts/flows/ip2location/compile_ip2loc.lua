--
-- compile.lua
-- 
-- helper methods. Compile IP2Location databases into a LevelDB for use 
-- by Trisul Network Analytics scripts. 
-- 
-- We use levelDB and not load the whole thing into memory due to the sheer size
-- Raw DB of Country/Region is > 300MB. Why levelDB? we love it!  and two threads
-- can share a handle. 
-- 
local leveldb=require'tris_leveldb' 
local bit=require'bit'

-- ip number to trisulkey format
function ipnum_tokey(ipnum)
	return string.format("%02X.%02X.%02X.%02X", 
		bit.rshift(ipnum,24), bit.band(bit.rshift(ipnum,16),0xff), bit.band(bit.rshift(ipnum,8),0xff), bit.band(bit.rshift(ipnum,0),0xff))
end

-- 
-- All databases are compiled into a single LevelDB 
-- 
function do_compile(leveldb_path, csv_file_path)

	local ldb = leveldb.new()
	ldb:open(leveldb_path);

	-- ASN is a prefix 
	process_csv_file(ldb, csv_file_path.. "/IP2LOCATION-LITE-ASN.CSV",
					 function(ldb, linearr)
						local k1 = ipnum_tokey(linearr[1])
						local k2 = ipnum_tokey(linearr[2])
						ldb:put("ASN:"..k2.."-"..k1, linearr[4]..' '..linearr[5])
				 end)

	-- IPR (Ip region  ) 
	-- IPC (Ip countr  )
	-- IPC (Ip city )
	process_csv_file(ldb, csv_file_path.. "/IP2LOCATION-LITE-DB3.CSV",
					 function(ldb, linearr)
						local k1 = ipnum_tokey(linearr[1])
						local k2 = ipnum_tokey(linearr[2])
						ldb:put("CTRY:"..k2.."-"..k1, linearr[3]..' '..linearr[4])
						ldb:put("STAT:"..k2.."-"..k1, linearr[3]..'_'..linearr[5])
						ldb:put("CITY:"..k2.."-"..k1, linearr[3]..'_'..linearr[6])
				 end)


	-- PRXY (Proxy-Type-CC) 
	process_csv_file(ldb, csv_file_path.. "/IP2PROXY-LITE-PX2.CSV",
					 function(ldb, linearr)
						local k1 = ipnum_tokey(linearr[1])
						local k2 = ipnum_tokey(linearr[2])
						ldb:put("PRXY:"..k2.."-"..k1, linearr[3]..' '..linearr[4])
				 end)

	ldb:put("last_updated_tm",tostring(os.time()))
	ldb:close() 


end


-- cbfn : callbackfunc(leveldb, lineitems) 
-- 
process_csv_file=function( ldb, csv_file, cbfunc) 
	local startts = os.time() 
	local beforemem = collectgarbage("count")

	-- check if we already compiled 
	local h_csv = io.popen("md5sum   "..csv_file)
	local md5=  h_csv:read("*a"):match('%w+')
	local _,md5_db = ldb:get(csv_file)

	if md5_db == md5  then 
		print("Skipping. No change detected in "..csv_file)
		return 
	end

	-- update  hash
	ldb:put(csv_file,"in progress")

	print("Processing ".. csv_file)
	local f,err = io.open(csv_file)
	if f == nil then 
		print("Error: opening CSV file "..csv_file.." msg="..err)
		return false, err 
	end 


	local nitems = 0 
	for l in f:lines() do 
	  local  validline=true 
	  if #l==0  or l:match("%s*#") then validline=false end 

	  -- break the CSV into parts 
	  if validline  then 
		local linearr={}
		for k in l:gmatch('".-"')  do
			linearr[#linearr+1] = k:gsub('"','')
		end 
		cbfunc( ldb, linearr) 
		nitems = nitems + 1
	  end
	end 

	local endts = os.time() 
	collectgarbage()
	local aftermem = collectgarbage("count")
	print(csv_file.. ":Loaded ".. nitems.." subnets in "..(endts-startts).." seconds. Mem usage = "..(aftermem-beforemem).." KB") 

	-- update  hash
	ldb:put(csv_file,md5)
end


if #arg ~= 2 then
	print("Usage : compile_ip2loc leveldbpath  directory_where_the_IP2LOCATION_files_are_kept")
	exit() 
end


print("compile_ip2loc:  Compiling IP2LOCATION files in "..arg[2].." into the LevebDB dir"..arg[1])
do_compile(arg[1], arg[2])

