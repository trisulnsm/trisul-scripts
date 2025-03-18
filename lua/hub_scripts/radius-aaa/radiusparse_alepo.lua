-- 2906536,0/0/0/1562_67B76806042ECC8B,5c67c53fbac5531edfe53113204c4351,<custid>,<nas-ip>,0/0/0/1562,2025-01-07 09:35:44,2025-01-27 18:24:56,NULL,1759752,7817.352d.1594,<framed-ip>,,

function getfileprefix()
    return 'alepoaaa*';
end

-- returns tv_sec
function timestampfromfilename(fn)
    local year, month, day, hour, min, sec = fn:match("(%d+)-(%d+)-(%d+)_(%d%d)(%d%d)(%d%d)")
    
    -- Ensure all components are extracted
    if not (year and month and day and hour and min and sec) then
        error("Failed to extract timestamp from filename: " .. fn)
    end

    local ts = os.time({
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day),
        hour = tonumber(hour),
        min = tonumber(min),
        sec = tonumber(sec)
    })
    return tonumber(ts) 
end

-- return a table { privateip, timefrom, timeto, user, subscriberid, fulline, nasip } 
-- radacctid,acctsessionid,acctuniqueid,customer_id,nasipaddress,nasportid,acctstarttime,acctupdatetime,acctstoptime,acctsessiontime,callingstationid,framed_ipv_4_address,framed_ipv_6_address,delegated_ipv6_prefix
function parseline(theline)
	-- print(theline)

	local tbl={}
	local theline_new = theline:gsub(",,",",<EMPTY>,")
	for word in string.gmatch(theline_new, '([^,]+)') do
		table.insert(tbl, word) 
	end

	-- for k,v in ipairs(tbl) do 
	-- 	print (k..'='..v)
	-- end 

	local framedipv4 = tbl[5]
	local customer_id = tbl[4]
	local acctstarttime = tbl[1]
	local acctupdatetime = tbl[1]
	local accsesstime = tbl[10]
	local subsciberid = tbl[3]

	if acctendtime == "NULL" then 
		acctendtime = acctupdatetime
	end 
	local nasip = tbl[6]

	if framedipv4 == nil or framedipv4=='0' or customer_id == 0 then
		return {} 
	end 

	

	local end_time_tvsec = tounix(acctupdatetime)
	local start_time_tvsec = tounix(acctupdatetime) - accsesstime
	print(start_time_tvsec)
	print(end_time_tvsec)

	return {
		customer_id,
		framedipv4,
		start_time_tvsec,
		end_time_tvsec,
		subsciberid,
		theline ,
		nasip
	}
end


function tounix( timeToConvert )
	-- 2024-07-29 15:23:24
	-- print('timeToConvert = ' ..timeToConvert) 
	local pattern = "(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)"
	local runmonth, runday, runyear, runhour, runminute, runseconds = timeToConvert:match(pattern)
	local convertedTimestamp = os.time({year = "20"..runyear, month = runmonth, day = runday, hour = runhour, min = runminute, sec = runseconds})
	return tonumber(convertedTimestamp)
end 

