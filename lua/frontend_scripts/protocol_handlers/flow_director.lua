--
-- flow_director.lua skeleton
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     protocol handler, 
-- DESCRIPTION: looks at packet and decides if it is NETFLOW or SFLOW based on router IP 
--
-- 
TrisulPlugin = { 


  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "FlowDirect",
    description = "Flow director based on router ip", -- optional
  },


  onload = function ()

  	T.ip_protocol_map = { 
		["180.179.17.253"] = "{462919DD-EE84-497C-AC6F-05D1162BCC5B}",   --  sflow  
		["180.179.17.254"] = "{CEF0774D-F1F3-40A6-8987-168BD69D9901}"    --  netflow 
	}

  end,


  -- protocol_handler  block
  -- 
  protocol_handler  = {

	-- new protocol for FLOWDIR 
	control = {
		guid  = "{0CED6B98-0D90-475C-D2D7-06A8E9E64B7C}",
		name  = "FLOWDIRECT",
	},


    -- WHEN CALLED: when lower layer is constructed and 
    -- return  ( nEaten, nextProtID) 
    parselayer = function(layer)

		local iplayer = layer:packet():find_layer("{0A2C724B-5B9F-4BA6-9C97-B05080558574}")
		local ipa = string.format("%d.%d.%d.%d", iplayer:getbyte(12), iplayer:getbyte(13), 
										iplayer:getbyte(14),iplayer:getbyte(15));

		local nextprotocol = T.ip_protocol_map[ipa]
		if nextprotocol then
			print("ip ="..ipa.. " next proto="..nextprotocol)
			return 0, nextprotocol
		end
	
    end,


  },
}
