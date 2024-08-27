
function getfileprefix()
    return 'pcastaaa*';
end

-- returns tv_sec
-- here we do -60 because the filename from fro (t-30 to t), hence upto T
-- this way the file arriving exactly at 00:00:00 midnight is mapped to he previous day slice 
-- instead of the current day slice 
function timestampfromfilename(fn)
	local ts = fn:match("(%d%d%d%d%d%d%d%d%d%d)")
    return tonumber(ts) - 60 
end

-- return a table privateip, timefrom, timeto, user, subscriberid, fulline
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

	local framedipv4 = tbl[12]
	local framedipv6 = tbl[13]
	local acctsessiontime = tbl[10] 
	local customer_id = tbl[4]
	local acctstarttime = tbl[7]
	local acctupdatetime = tbl[8]
	local acctendtime = tbl[9]
	if acctendtime == "NULL" then 
		acctendtime = acctupdatetime
	end 

	-- Framed v6
	if framedipv4 == "<EMPTY>" or framedipv4 == nil then
		framedipv4 = framedipv6
	end 

	if framedipv4 == nil or customer_id == 0 then
		return {} 
	end 

	return {
		customer_id,
		framedipv4,
		tounix(acctstarttime),
		tounix(acctendtime),
		"",
		theline 
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

