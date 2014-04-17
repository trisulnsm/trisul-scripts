--
-- tcphdr.lua
--
--  Prints the TCP headers to stdout - does not actually meter anything 
--
--  Demonstrates how you can work with 
--   1) The Buffer object
--   2) The Layer
--   3) The Packet 
--
TrisulPlugin = {

  id = {
    name = "TCPHDR ",
    description = "Demo - prints tcp header ",
    author = "Unleash",
    version_major = 1,
    version_minor = 0,
  },

  simplecounter = {

    -- attach to the TCP protocol http://trisul.org/docs/ref/guid.html#protocols
    protocol_guid = "{77E462AB-2E42-42ec-9A58-C1A6821D6B31}",

    -- onpacket
    onpacket = function(engine,layer)

      local buff = layer:rawbytes() 

      -- T.debugger({ engine = engine, layer = layer })
      --
      
      print("Source port = " .. buff:hval_16(0))
      print("Dest port   = " .. buff:hval_16(2))
      print("Seq number  = " .. buff:hval_32(4))
      print("Ack number  = " .. buff:hval_32(8))

      local fval= buff:hval_16(12)

      -- how to extract a single bit ]
      -- since we are using LuaJIT we cant use the new bit32 library in Lua5.2
      --
      print("RST flag    = " .. tostring(T.util.testbit32(fval,2)))
      print("SYN flag    = " .. tostring(T.util.testbit32(fval,1)))
      print("FIN flag    = " .. tostring(T.util.testbit32(fval,0)))

      -- can also test for a single bit from the layer object directly
      -- for example RST is bit number 109 in the TCP header
      print("RST flag alt   = " .. tostring(layer:testbit(109)))

      -- get 4 bit frame offset 
      print("Frame offset words  = " .. T.util.bitval32(layer:getbyte(12),7,4))
	  -- or from the buffer
      print("Frame offset words = " .. T.util.bitval32(buff:hval_8(12),7,4))


    end,


   },


}

