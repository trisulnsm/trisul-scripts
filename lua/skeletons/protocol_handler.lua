--
-- protocol_handler.lua skeleton
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     protocol handler, 
-- DESCRIPTION: dissects a protocol at a given layer, return number of bytes 'eaten' and then
--				the next layer. 
-- 
TrisulPlugin = { 


  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "FlowDirect",
    description = "Flow director based on router ip", -- optional
  },


  -- protocol_handler  block
  -- 
  protocol_handler  = {

	-- new protocol for FLOWDIR 
	control = {
		guid  = "{0CED6B98-0D90-475C-D2D7-06A8E9E64B7C}",  -- new protocol GUID, use tp testbench guid to create
		name  = "FLOWDIRECT",  -- new protocol name 
	},


    -- WHEN CALLED: when lower layer is constructed and 
    -- return  ( nEaten, nextProtID) 
    parselayer = function(layer)

		-- return nEaten, nextProtocolGUID
		-- if you have no idea about next protocol, return nothing

	
    end,


  },
}
