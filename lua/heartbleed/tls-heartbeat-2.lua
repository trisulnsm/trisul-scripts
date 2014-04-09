-- tls-heartbleed.lua
--
-- Detects TLS heartbeats  (builds on tls-heartbeat.lua) 
--	This one saves the stuff in Heartbeat response 
-- 

TrisulPlugin = {

  id = {
    name = "TLS Heartbleed ",
    description = "Log req/resp in one line ",
    author = "trisul-scripts", version_major = 1, version_minor = 0,
  },

  onload = function()
	pending_hb_requests = { } 
  end,


  flowmonitor  = {

	onflowattribute = function(engine,flow,timestamp, nm, valbuff)

	     if nm == "TLS:RECORD" then
		 	local  content_type = valbuff:hval_8(0)

			if content_type == 24 then
				local hb_len = valbuff:hval_16(6) 

				if valbuff:hval_8(5) == 1  then 

					-- save size of outstanding TLS hb request 
					pending_hb_requests[flow:id()] = valbuff:size()

				else

					local req_len  = pending_hb_requests[flow:id()]
					if reqlen and req_len ~= hb_len then

						-- mismatch between HB request and response sizes
						-- write out the payload 
						local of = io.open("/tmp/hb-"..flow:id()..".dump","w")
						local payload = valbuff:tostring(9,valbuff:size()-9)
						of:write(payload)
						of:close()

					end
				end
			end

	 	 elseif  nm == "^D" then 
		 	-- connection closed, free up map so it can be garbage collected 
		 	pending_hb_requests[flow:id()]=nil 
		 end
		 
    end,

  },

}
