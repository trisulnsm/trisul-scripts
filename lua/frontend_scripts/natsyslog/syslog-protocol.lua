--
-- SYSLOG 
-- 
TrisulPlugin = { 


  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "SYSLOG",
    description = "Syslog protocol udp 514", 
  },


  -- protocol_handler  block
  -- 
  protocol_handler  = {

  -- new protocol for FLOWDIR 
  control = {
    guid  = "{4323003E-D060-440B-CA26-E146C0C7DB4E}",  
    name  = "SYSLOG",  
	host_protocol_guid = '{14D7AB53-CC51-47e9-8814-9C06AAE60189}',
	host_protocol_ports = { 514 }
  },


  -- WHEN CALLED: when lower layer is constructed and 
  -- return  ( nEaten, nextProtID) 
  parselayer = function(layer)


	    return layer:layer_bytes(),nil
  end,


  },
}
