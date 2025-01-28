-- 2906536,0/0/0/1562_67B76806042ECC8B,5c67c53fbac5531edfe53113204c4351,<custid>,<nas-ip>,0/0/0/1562,2025-01-07 09:35:44,2025-01-27 18:24:56,NULL,1759752,7817.352d.1594,<framed-ip>,,

function getfileprefix()
    return 'pcastaaa_0_*';
end

-- returns tv_sec
function timestampfromfilename(fn)
	local ts = fn:match("(%d%d%d%d%d%d%d%d%d%d)")
    return tonumber(ts) 
end

-- return a table { privateip, timefrom, timeto, user, subscriberid, fulline, nasip } 
-- radacctid,acctsessionid,acctuniqueid,customer_id,nasipaddress,nasportid,acctstarttime,acctupdatetime,acctstoptime,acctsessiontime,callingstationid,framed_ipv_4_address,framed_ipv_6_address,delegated_ipv6_prefix
function parseline(theline)

	local tbl={}
	local theline_new = theline:gsub(",,",",<EMPTY>,")
	for word in string.gmatch(theline_new, '([^,]+)') do
		table.insert(tbl, word) 
	end

--[[
	for k,v in ipairs(tbl) do 
		print (k..'='..v)
	end
--]]

	local framedipv4 = tbl[15]
	local customer_id = tbl[2].."|"..tbl[3].."|".." ".."|".. tbl[4] .. "| | "
	local acctstarttime = tbl[10]
	local acctupdatetime = tbl[11]
	local acctendtime = tbl[12]
	local subscriberid= tbl[7]
	if acctendtime == "NULL" then 
		acctendtime = acctupdatetime
	end 
	local nasip = tbl[8]

	if framedipv4 == nil or customer_id == 0 then
		return {} 
	end 

	return {
		customer_id,
		framedipv4,
		tounix(acctstarttime),
		tounix(acctendtime),
		subscriberid,
		theline ,
		nasip
	}
end


function tounix( timeToConvert )
	-- 2024-07-29 15:23:24
	-- print('timeToConvert = ' ..timeToConvert) 
	local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
	local runyear, runmonth, runday, runhour, runminute, runseconds = timeToConvert:match(pattern)
	local convertedTimestamp = os.time({year = runyear, month = runmonth, day = runday, hour = runhour, min = runminute, sec = runseconds})
	return tonumber(convertedTimestamp)
end 

