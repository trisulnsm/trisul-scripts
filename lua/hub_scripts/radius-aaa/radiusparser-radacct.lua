function getfileprefix()
    return 'radacct*';
end

-- returns tv_sec
function timestampfromfilename(fn)
    local year, month, day, hour, min, sec = fn:match("(%d%d%d%d)(%d%d)(%d%d)_(%d%d)(%d%d)(%d%d)")
    
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
function parseline(theline)
	-- print(theline)

	local tbl={}
	local theline_new = theline:gsub(",,",",<EMPTY>,")
	for word in string.gmatch(theline_new, '([^,]+)') do
		table.insert(tbl, word) 
	end

	--  for k,v in ipairs(tbl) do 
	--   	print (k..'='..v)
	--  end 

	local subsciberid = tbl[3]
	local customer_id = tbl[4]
	local nasip = tbl[6]
	local acctstarttime = tbl[9]
	local acctstoptime = tbl[10]
	local acctsesstime = tbl[11]
	local framedipv4 = tbl[21]
	local acctupdatetime = tbl[25]


	if acctstoptime == "<EMPTY>" then
		acctstoptime = acctupdatetime
	end

	
	if framedipv4 == '0'  or framedipv4=='<EMPTY>' or customer_id == 0 then
		return {} 
	end 


	-- print('-------------------------------')
	-- print('customer_id = ' .. customer_id)
	-- print('framedipv4 = ' .. framedipv4)
	-- print('acctstarttime = ' .. tounix(acctstarttime))
	-- print('acctstoptime = ' .. tounix(acctstoptime))
	-- print('nasip = ' .. nasip)
	-- print('subsciberid = ' .. subsciberid)


	return {
		customer_id,
		framedipv4,
		tounix(acctstarttime),
		tounix(acctstoptime),
		subsciberid,
		theline ,
		nasip
	}
end


function tounix( timeToConvert )
	-- 2024-07-29 15:23:24
	local pattern = "(%d+)-(%d+)-(%d+)%s+(%d+):(%d+):(%d+)"
	local runyear, runmonth, runday, runhour, runminute, runseconds = timeToConvert:match(pattern)
	local convertedTimestamp = os.time({year = runyear, month = runmonth, day = runday, hour = runhour, min = runminute, sec = runseconds})
	return tonumber(convertedTimestamp)
end 

