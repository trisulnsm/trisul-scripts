# Radius Parsers 


This directory contains RADIUS dump parsers in LUA for use with Trisul IPDR AAAING process. 


See `man trisul_aaaing` 


## Purpose

The purpose of this repository is to make available common parsers for various RADIUS AAA formats.

The AAAING process can use a LUA file to parse each line in any format.  The lua files in this directory
support various formats.


Modify the dump filename pattern as per your choice.


## LUA Script Docs

The purpose of the AAA LUA script 
  3. Specify a file prefix which would trigger this lua script 
  1. Extract a timestamp from a file name 
  2. Parse a single line in the AAA dump file and return a LUA table 



The structure is shown below

```

-- return a prefix that triggers this script 
function getfileprefix()
    return 'net1aaa*';
end


-- From the file name return a tv_sec (unix epoch) 
function timestampfromfilename(fn)
	local ts = fn:match("(%d%d%d%d%d%d%d%d%d%d)")
	return tonumber(ts) 
end



-- return a table { privateip, timefrom, timeto, user, subscriberid, fulline, nasip } 
-- radacctid,acctsessionid,acctuniqueid,customer_id,nasipaddress,nasportid,
--   acctstarttime,acctupdatetime,acctstoptime,acctsessiontime, 
--     callingstationid,framed_ipv_4_address,framed_ipv_6_address,delegated_ipv6_prefix

function parseline(theline)


	return {
		customer_id,
		framedipv4,
		tounix(acctstarttime),
		tounix(acctendtime),
		subscriber_id,
		theline ,
		nasip
	}

end 

``` 


See the samples 


