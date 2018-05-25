--
-- compile.lua
-- 
-- GeoLite compiler 
-- 
package.path = package.path .. ';helpers/?.lua'

local IPPrefixDB=require'ipprefixdb'

local bit=require'bit'
local csv=require'csv'

-- 
-- We compile the following three databases 
-- THREE databases ASN, COUNTRY, CITY 
-- 
function do_compile(csv_file_path, leveldb_path )

	local ldb = IPPrefixDB.new()
	ldb:open(leveldb_path);

	-- ASN is a prefix 
	ldb:set_databasename("ASN");
	process_csv_file(ldb, csv_file_path.. "/GeoLite2-ASN-Blocks-IPv4.csv",
					 function(ldb, linearr)
						ldb:put_cidr(linearr[1],linearr[2]..' '..linearr[3])
				 end)

	-- Country 
	ldb:set_databasename("CTRY");
	process_csv_file(ldb, csv_file_path.. "/GeoLite2-Country-Blocks-IPv4.csv",
					 function(ldb, linearr)
						ldb:put_cidr(linearr[1],linearr[2])
				 end)

	-- IPv6 country only 
	ldb:set_databasename("V6CTRY");
	process_csv_file(ldb, csv_file_path.. "/GeoLite2-Country-Blocks-IPv6.csv",
					 function(ldb, linearr)
						ldb:put_ipv6_cidr(linearr[1],linearr[2])
				 end)


	-- City 
	ldb:set_databasename("CITY");
	process_csv_file(ldb, csv_file_path.. "/GeoLite2-City-Blocks-IPv4.csv",
					 function(ldb, linearr)
						ldb:put_cidr(linearr[1],linearr[2])
				 end)

	-- Country Code ldb:set_databasename("CTRYCODE");
	process_csv_file(ldb, csv_file_path.. "/GeoLite2-Country-Locations-en.csv",
					 function(ldb, linearr)
						ldb:putraw(linearr[1],linearr[6])
				 end)

	-- City Code 
	-- US_NJ_Middletown
	ldb:set_databasename("CITYCODE");
	process_csv_file(ldb, csv_file_path.. "/GeoLite2-City-Locations-en.csv",
					 function(ldb, linearr)
						ldb:putraw(linearr[1],linearr[5].."_"..linearr[7].."-"..linearr[11])
				 end)


	ldb:putraw("last_updated_tm",tostring(os.time()))
	ldb:close() 

end


-- cbfn : callbackfunc(leveldb, lineitems) 
-- 
process_csv_file=function( ldb, csv_file, cbfunc) 
	local startts = os.time() 

	-- check if we already compiled 
	local h_csv = io.popen("md5sum   "..csv_file)
	local md5=  h_csv:read("*a"):match('%w+')
	local _,md5_db = ldb:getraw(csv_file)
	if md5_db == md5  then 
		print("Skipping. No change detected in "..csv_file)
		return 
	end


	-- loop every line in CSV 
	print("Processing ".. csv_file)
	local nitems=0
	local f = csv.open(csv_file)
	for fields in f:lines() do
		cbfunc( ldb, fields) 
		nitems = nitems + 1
	end


	-- wrapup  and update hash 
	local endts = os.time() 
	print(csv_file.. ":Loaded ".. nitems.." subnets in "..(endts-startts).." seconds. ") 
	ldb:putraw(csv_file,md5)
end


if #arg ~= 2 then
	print("Usage : compile_ip2loc directory-with-IP2LOC-databases  output-leveldb-database")
	return  
end

print("compile_geolite2:  Compiling GeoLite2 CSV files in "..arg[1].." into the LevebDB dir"..arg[2])
do_compile(arg[1], arg[2])
