--
-- IPFIX raw parser for NAT logs 
-- 
-- {F15F08A9-F3E0-4722-4D97-31CCF0743E4E}
-- DEFINE_GUID(GUID_xxx,0xF15F08A9,0xF3E0,0x4722,0x4D,0x97,0x31,0xCC,0xF0,0x74,0x3E,0x4E);

TrisulPlugin = { 


  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "NAT-IPFIX",
    description = "IPFIX protocol default udp 1025", 
  },


  -- protocol_handler  block
  -- 
  protocol_handler  = {

  -- new protocol for FLOWDIR 
  control = {
    guid  = "{F15F08A9-F3E0-4722-4D97-31CCF0743E4E}",
    name  = "NAT-IPFIX",  
	host_protocol_guid = '{14D7AB53-CC51-47e9-8814-9C06AAE60189}',
	host_protocol_ports = { 1025 }
  },


  -- WHEN CALLED: when lower layer is constructed and 
  -- return  ( nEaten, nextProtID) 
  parselayer = function(layer)
	    return layer:layer_bytes(),nil
  end,


  },
}
