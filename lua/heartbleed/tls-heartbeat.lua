-- tls-heartbleed.lua
--
-- Detects TLS heartbeats 
-- 	simple version - alert if you see a heartbeat 
-- 
-- content types in 
-- http://www.iana.org/assignments/tls-parameters/tls-parameters.xhtml#tls-parameters-5
--
--[[ 

	struct {
		HeartbeatMessageType type;
		uint16 payload_length;
		opaque payload[HeartbeatMessage.payload_length];
		opaque padding[padding_length];
	} HeartbeatMessage;

--]]

TrisulPlugin = {

  id = {
    name = "TLS Heartbleed ",
    description = "Log req/resp in one line ",
    author = "trisul-scripts", version_major = 1, version_minor = 0,
  },



  flowmonitor  = {

	onflowattribute = function(engine,flow,timestamp, nm, valbuff)

	     if nm == "TLS:RECORD" then
		 	local  content_type = valbuff:hval_8(0)

			if content_type == 24 then
				--
				-- he be our man !  (heartbeat = ctype 24) 
				--
				-- if you're trying to fake the inner length, we get you !
				--
				local hb_len = valbuff:hval_16(6) 
				if hb_len > valbuff:size()  then
					engine:add_alert_full( 
					"{9AFD8C08-07EB-47E0-BF05-28B4A7AE8DC9}", -- GUID for IDS 
					flow:id(), 								  -- flow 
					"sid-8000002",							  -- a sigid (private range)
					"trisul-lua-gen",			  			  -- classification
					"sn-1",                                   -- priority 1, 
					"Possible heartbleed situation ")		  -- message 

				end
			end
		 end
    end,

  },

}
