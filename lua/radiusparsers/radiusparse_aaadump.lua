default_config={
 	file_prefix_regex="^session_dum*",
	file_timestamp_regex="(%d%d%d%d%d%d%d%d%d%d)",
	seperator=",",
	framed_ipv4_pos=11,
	customer_id_pos=1,
	acc_start_time_pos=22,
	acc_end_time_pos=23,
	acc_update_time_pos=23,
    session_time_stamp_regex="(%d+).(%d+).(%d+) (%d+):(%d+):(%d+)",
	add_customer_info=true,
	nas_ip_pos=17,

}

active_config=default_config

function getfileprefix()
	print(active_config.file_prefix_regex)
	return active_config.file_prefix_regex
end

-- returns tv_sec
function timestampfromfilename(fn)
	local ts=fn:match(active_config.file_timestamp_regex)
	return tonumber(ts) 
end

-- return a table { privateip, timefrom, timeto, user, subscriberid, fulline, nasip } 
-- radacctid,acctsessionid,acctuniqueid,customer_id,nasipaddress,nasportid,acctstarttime,acctupdatetime,acctstoptime,acctsessiontime,callingstationid,framed_ipv_4_address,framed_ipv_6_address,delegated_ipv6_prefix
function parseline(theline)
	local tbl={}
	local theline_new = theline:gsub(",,",",<EMPTY>,")
	while theline_new:match("||")
	do
	 	theline_new = theline_new:gsub("||","| |")
	end
	while theline_new:match(",,")
	do
	 	theline_new = theline_new:gsub(",,",", ,")
	end
	for word in string.gmatch(theline_new, '([^|,]+)') do
		table.insert(tbl, word) 
	end

	for k,v in ipairs(tbl) do 
		print (k..'='..v)
	end 

	local framedipv4 = tbl[active_config.framed_ipv4_pos]
	local nasip = tbl[active_config.nas_ip_pos]
	local acctsessiontime = tbl[active_config.acc_start_time_pos] 

	local customer_id = tbl[active_config.customer_id_pos]
	if active_config.add_customer_info == true then
		customer_id = customer_id.."|"..tbl[4].."|"..tbl[6].."|"..tbl[5].."| |"
        end

	local acctstarttime = tbl[active_config.acc_start_time_pos]
	local acctupdatetime = tbl[active_config.acc_update_time_pos]
	local acctendtime = tbl[active_config.acc_end_time_pos]
	if acctendtime == "NULL" then 
		acctendtime = acctupdatetime
	end 
	if customer_id:match(":(.*)") then
		customer_id=customer_id:match(":(.*)")
	end
	if framedipv4 == nil or customer_id == 0 or framedipv4 == ' ' then
		return {} 
	end 

	return {
		customer_id,
		framedipv4,
		tounix(acctstarttime),
		tounix(acctendtime),
		"",
		theline,
		nasip
	}
end


function tounix( timeToConvert )
	-- 2024-07-29 15:23:24
	-- print('timeToConvert = ' ..timeToConvert) 
	local pattern = active_config.session_time_stamp_regex
	local runday,runmonth,runyear,runhour, runminute, runseconds = timeToConvert:match(pattern)
	local convertedTimestamp = os.time({year = runyear, month = runmonth, day = runday, hour = runhour, min = runminute, sec = runseconds})
	return tonumber(convertedTimestamp)
end 

