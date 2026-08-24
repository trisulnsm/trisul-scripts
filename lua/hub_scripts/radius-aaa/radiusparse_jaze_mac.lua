--Username,User ID,Zone Name,Name,Phone,Email,Address,Gender,Age,Login Type,Mac,IP Address,IPV6 Prefix,Delegated IPV6 Prefix,Device Type,Browser,AP Mac,AP IP Address,Download,Upload,Total Data,Social Profile,Start Time,Stop Time

default_config={
 	file_prefix_regex="^session_dum*",
	file_timestamp_regex="(%d%d%d%d%d%d%d%d%d%d)",
	seperator=",",
	customer_id_pos=1,
	
	customer_name_pos=4,
	customer_phone_pos=5,
	customer_email_pos=6,
	customer_address_pos=7,
	customer_mac_pos=11,
	framed_ipv4_pos=12,
	framed_ipv6_pos=13,
	nas_ip_pos=18,
	acc_start_time_pos=23,
	acc_end_time_pos=24,
    session_time_stamp_regex="(%d+).(%d+).(%d+) (%d+):(%d+):(%d+)",
	add_customer_info=true,
	

}

active_config=default_config

function getfileprefix()
	print(active_config.file_prefix_regex)
	return active_config.file_prefix_regex
end

-- returns tv_sec
function timestampfromfilename(fn)
    print(fn) 
	local ts=fn:match(active_config.file_timestamp_regex)
	return tonumber(ts) 
end

-- CSV split that keeps commas inside quoted fields
function split_csv(line)
	local tbl = {}
	local field = {}
	local in_quotes = false
	local i = 1
	local len = #line
	while i <= len do
		local c = line:sub(i, i)
		if c == '"' then
			if in_quotes and line:sub(i + 1, i + 1) == '"' then
				table.insert(field, '"')
				i = i + 1
			else
				in_quotes = not in_quotes
			end
		elseif (c == "," or c == "|") and not in_quotes then
			local v = table.concat(field)
			if v == "" then
				v = " "
			end
			table.insert(tbl, v)
			field = {}
		else
			table.insert(field, c)
		end
		i = i + 1
	end
	local v = table.concat(field)
	if v == "" then
		v = " "
	end
	table.insert(tbl, v)
	return tbl
end

-- return a table { privateip, timefrom, timeto, user, subscriberid, fulline, nasip } 
-- radacctid,acctsessionid,acctuniqueid,customer_id,nasipaddress,nasportid,acctstarttime,acctupdatetime,acctstoptime,acctsessiontime,callingstationid,framed_ipv_4_address,framed_ipv_6_address,delegated_ipv6_prefix
function parseline(theline)
	local tbl = split_csv(theline)

	local framedipv4 = tbl[active_config.framed_ipv4_pos]
	local nasip = tbl[active_config.nas_ip_pos]
	local acctsessiontime = tbl[active_config.acc_start_time_pos] 

	local customer_id = tbl[active_config.customer_id_pos]
	-- Remove an optional prefix only from the original username. Doing this
	-- after appending the MAC would mistake its first colon for the prefix.
	if customer_id and customer_id:match(":(.*)") then
		customer_id = customer_id:match(":(.*)")
	end

	local function col(pos)
		if pos == nil then
			return ""
		end
		local v = tbl[pos]
		if v == nil or v == "" or v == "<EMPTY>" or v == " " then
			return ""
		end
		-- strip surrounding quotes/spaces; replace | so output stays 6 fields
		v = v:gsub('^%s*"?', ""):gsub('"?%s*$', ""):gsub("|", "/")
		return v
	end

	-- Excel-safe quoted address (commas stay inside one cell)
	local function quoted_address(pos)
		local v = col(pos)
		if v == "" then
			return ""
		end
		v = v:gsub('"', '""')
		return '"' .. v .. '"'
	end

	-- order: customer_id | name | phone | email | address | mac
	if active_config.add_customer_info == true then
		customer_id = table.concat({
			customer_id or "",
			col(active_config.customer_name_pos),
			col(active_config.customer_email_pos),
			col(active_config.customer_phone_pos),
			" ",
			col(active_config.customer_address_pos),
			col(active_config.customer_mac_pos),
			
		}, "|")
	else
		customer_id = (customer_id or "") .. "|||||||"
	end
	--customer_id = customer_id..'|'

	local acctstarttime = tbl[active_config.acc_start_time_pos]
	local acctupdatetime = tbl[active_config.acc_update_time_pos]
	local acctendtime = tbl[active_config.acc_end_time_pos]
	if acctendtime == "NULL" then 
		acctendtime = acctupdatetime
	end 

	if framedipv4 == nil or framedipv4 == " " or framedipv4 == "" or framedipv4 == "<EMPTY>" or framedipv4 == "NULL"
		or customer_id == 0
		or tbl[active_config.customer_id_pos] == "Username"
		or acctstarttime == "Start Time" then
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

