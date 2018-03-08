--
-- ua-resource-monitor 
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     User-Agent parser 
-- DESCRIPTION: Uses Regex User Agent parser ua-parser  
--              https://github.com/ua-parser/uap-core 
-- 

local YAML=require'tinyyaml'

TrisulPlugin = { 

  -- id block
  --
  id =  {
    name = "User-Agent Parser ",
    description = "Extract Browser,Device,OS", 
  },


  -- WHEN CALLED : your LUA script is loaded into Trisul 
  onload = function()
	local input_file = io.open("/tmp/regexes.yaml","r")
	local contents = input_file:read("*a")
	local doc = YAML.parse(contents) 

	T.ua_table={} 
	for k,v in pairs(doc['user_agent_parsers'])  do 
		local case_s = (v['regex_flag']~='i')
		T.ua_table[#T.ua_table+1] = {regex_compiled=T.re2(v['regex'],{case_sensitive=case_s}), 
									 regex_str=v['regex'], 
									 family_replacement=v['family_replacement'], 
									 hits=0 }
	end
	print("LOADED  "..#T.ua_table.." User Agent regexps")

	T.dev_table = { } 
	for k,v in pairs(doc['device_parsers'])  do 
		local case_s = (v['regex_flag']~='i')
		T.dev_table[#T.dev_table+1] = {regex_compiled=T.re2(v['regex'],{case_sensitive=case_s}), 
									 regex_str=v['regex'], 
									 dev_replacement=v['device_replacement'], 
									 brand_replacement=v['brand_replacement'] or "", 
									 model_replacement=v['model_replacement'] or "", 
									 hits=0 }
	end
	print("LOADED  "..#T.dev_table.." Device regexps")


	T.os_table = {} 
	for k,v in pairs(doc['os_parsers'])  do 
		local case_s = (v['regex_flag']~='i')
		T.os_table[#T.os_table+1] = {regex_compiled=T.re2(v['regex'], {case_sensitive=case_s}), 
									 regex_str=v['regex'], 
									 os_replacement=v['os_replacement'], 
									 os_v1_replacement=v['os_v1_replacement'] or "", 
									 os_v2_replacement=v['os_v2_replacement'] or "", 
									 hits=0 }
	end
	print("LOADED  "..#T.os_table.." OS regexps")
  end,



  -- resource_monitor block 
  --
  resource_monitor  = {

    -- listen to User-Agent resource 
    resource_guid = '{ED5CA168-1E17-44E0-7ABD-65E5C2DFAD21}',


    -- Each user-agent resource is flushed, use the Regexes to process 
    onflush = function(engine, resource) 

		local browser_str, device_str, os_str 


		-- user agents  (browsers) 
		for _,rx in ipairs(T.ua_table) do 
			local fmatch,browser,major_version =  rx.regex_compiled:partial_match_n( resource:uri())
			if fmatch then 
				rx.hits = rx.hits + 1

				if rx.family_replacement then
					browser_str = rx.family_replacement 
				else 
					browser_str = browser.."/"..major_version
				end 
				print("BROWSER = "..browser_str) 

				table.sort(T.ua_table, function( v1, v2 ) return v1.hits > v2.hits ; end ) 
				break
			end
		end  

		-- Devices  
		for _,rx in ipairs(T.dev_table) do 
			local fmatch,dev,brand =  rx.regex_compiled:partial_match_n( resource:uri())
			if fmatch then 
				rx.hits = rx.hits + 1

				if rx.device_replacement then 
					device_str = rx.device_replacement..rx.brand_replacement..rx.model_replacement
				else 
					device_str = dev
				end

				print("DEVICE = "..device_str)

				table.sort(T.dev_table, function( v1, v2 ) return v1.hits > v2.hits ; end ) 
				break
			end
		end  

		-- OS 
		for _,rx in ipairs(T.os_table) do 
			local fmatch,os,v1,v2 =  rx.regex_compiled:partial_match_n( resource:uri())
			if fmatch then 
				rx.hits = rx.hits + 1

				if rx.os_replacement  then
					os_str = rx.os_replacement ..rx.os_v1_replacement
				else 
					os_str = os.."-"..(v1 or "")..(v2 or "")  
				end 
				print("OS = "..os_str) 
				table.sort(T.os_table, function( v1, v2 ) return v1.hits > v2.hits ; end ) 
				break
			end
		end  


		-----------------------
		-- Analytics  section 
		-----------------------

		-- Add flow tags 
		if browser_str then engine:tag_flow( resource:flow():id(), browser_str) end 
		if device_str then engine:tag_flow( resource:flow():id(), device_str) end 
		if os_str then engine:tag_flow( resource:flow():id(), os_str) end 

		-- Add edges 
		if browser_str then engine:add_flow_edges( resource:flow():id(), "{747F125F-2838-4A76-6D44-55974DE58F78}", browser_str)  end 
		if os_str then  engine:add_flow_edges( resource:flow():id(), "{0F67F47E-A407-4047-2AF6-8E25FEC75C3A}", os_str)  end 
		if device_str  then engine:add_flow_edges( resource:flow():id(), "{EB232F1A-05E6-45E7-1888-9AF224511E6D}", device_str)  end 

		-- More edges
		if browser_str and os_str then  
			engine:add_edge("{747F125F-2838-4A76-6D44-55974DE58F78}", browser_str, 
							"{0F67F47E-A407-4047-2AF6-8E25FEC75C3A}", os_str)
		end 

		-- Add metrics  
		if browser_str then 
			engine:update_counter( "{747F125F-2838-4A76-6D44-55974DE58F78}", 
								browser_str, 0 , 1)  
		end 
    end,
  },
}
