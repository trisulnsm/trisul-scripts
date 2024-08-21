
function getfileprefix()
    return 'aaa*';
end

-- returns tv_sec
function timestampfromfilename(fn)
	local ts = fn:match("(%d%d%d%d%d%d%d%d%d%d)")
    return tonumber(ts) 
end

-- return a table privateip, timefrom, timeto, user, subscriberid, fulline
-- VC1017,100.68.3.119,192.168.88.198,1C:5F:2B:8E:06:DF,08/05/2020 20:45:13,
function parseline(theline)

	local tbl={}
	local theline_new = theline:gsub(",,",",<EMPTY>,")
	for word in string.gmatch(theline_new, '([^,]+)') do
		table.insert(tbl, word) 
	end

	local customer_id = tbl[1]
	local framedipv4 = tbl[2]
	local acctstarttime = tbl[5]
	local acctupdatetime = tbl[7]
	local acctendtime = tbl[6]
	if acctendtime == "<EMPTY>" then 
		acctendtime = acctupdatetime
	end 

	if framedipv4 == nil or customer_id == 0  or acctendtime == nil then
		return {} 
	end 

--[[
	for k,v in ipairs(tbl) do 
		print (k..'='..v)
	end 
--]]

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
    -- mm/dd/yyyy hh:mm:ss
	-- 08/05/2020 20:45:13,
	-- print('timeToConvert = ' ..timeToConvert) 
	local pattern = "(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)"
	local runmonth, runday, runyear, runhour, runminute, runseconds = timeToConvert:match(pattern)
	local convertedTimestamp = os.time({year = runyear, month = runmonth, day = runday, hour = runhour, min = runminute, sec = runseconds})
	return tonumber(convertedTimestamp)
end 

