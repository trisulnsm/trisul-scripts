--
-- vastflow.lua
--
--  reads the flow CSV dump in VAST 2013 
--  published by VAST at ... http://vacommunity.org/VAST+Challenge+2013%3A+Mini-Challenge+3
--
local dbg = require("debugger")

-- helpers


-- in trisul: ipv4 keys look like XX.XX.XX.XX 
function  toip_format( dotted_ip )
  local b1, b2, b3, b4 =  dotted_ip:match("(%d+).(%d+).(%d+).(%d+)")
    return string.format("%02X.%02X.%02X.%02X",
                b1, b2, b3, b4 ) 
end

-- in trisul: port keys look like p-XXXX
function toport_format( strkey)
    return string.format("p-%04X", strkey)
end

-- in trisul: proto keys look like XX - UDP = IP proto 17 = 11 
function toproto_format( strkey)
    return string.format("%02X", strkey)
end


-- in trisul: flow keys look like
function toflow_format( ipa, pra, ipz, prz, proto )
  return string.format("%02XA:%s:%s_%s:%s", proto, ipa, pra,ipz, prz )
end


TrisulPlugin = {

    id = {
      name = "VAST flow input filter CSV",
      description = "Offline input ",
      author = "Unleash", version_major = 1, version_minor = 0,
    },

    onload = function()
      T.host:log(T.K.loglevel.INFO, 
              "OnLoad Custom Input filter LUA plugin, Hi!  - ready ");

      datfile = io.open("/home/vivek/pcaps/nf25k.csv.sorted")
      lastts = 0 
      skipped_late = 0 
      count = 0 
    end,


    onunload = function ()
      T.host:log(T.K.loglevel.INFO, 
                "OnUnload Custom Input filter LUA plugin, bye!");
    end,


    inputfilter  = {

      -- nextmetrics
      -- read the next line and update flow metrics 
      step  = function(packet, engine)


        local nextline = datfile:read()

        -- check if end of file, 
        -- then pipeline must shutdown by returning false 
        --
        if nextline == nil or #nextline == 0 then
      print("LASJDLA="..count.." skip="..skipped_late   )
        return false
      end

      count = count + 1 

      -- a utility method , can also use LUA to split 
      local fields = T.util.split(nextline,",")

      -- not a number? , call me again for the next line 
      if string.match(fields[1],"[a-zA-Z]")  then
        return true
      end 
        
      -- timestamp VAST format  tv_sec.tv_usec
      local tv_sec, tv_usec = string.match(fields[1],"(%d+).(%d+)")
      tv_sec = tonumber(tv_sec)

      if tv_sec <  lastts then 
        tv_sec = lastts 
        skipped_late = skipped_late + 1 
        return true
      else 
        lastts = tv_sec 
      end 

      -- set the timestamp of the 'packet' , all the update_ below inherit that
      packet:set_timestamp(tv_sec );

      -- protocol 4
      local ip_proto = toproto_format(fields[4])

      -- ip,port
      local ipa , ipz = toip_format(fields[6]), toip_format(fields[7])
      local porta, portz = toport_format(fields[8]), toport_format(fields[9])

      -- duration_secs
      local dur_secs = fields[12]

      -- payload bytes 
      local azpayload, zapayload  = fields[13], fields[14]

      -- byts
      local azbytes, zabytes = fields[15], fields[16]

      -- packets
      local azpackets, zapackets = fields[17], fields[18]


        -- update metrics
      engine:update_counter( "{393B5EBC-AB41-4387-8F31-8077DB917336}", "TOTALBW", 0, azbytes +  zabytes)

      -- hosts 
      engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  ipa, 0, azbytes + zabytes);
      engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  ipa, 1, zabytes);
      engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  ipa, 2, azbytes );

      engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  ipz, 0, azbytes + zabytes);
      engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  ipz, 1, zabytes);
      engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  ipz, 2, azbytes );


      -- network layer
      engine:update_counter( "{E89BCD56-30AD-40F5-B1C8-8B7683F440BD}",  ip_proto, 0, azbytes + zabytes);

      engine:update_counter( "{C51B48D4-7876-479E-B0D9-BD9EFF03CE2E}",  porta, 0, azbytes  + zabytes);

            -- flow 
      local flowkey =  toflow_format( ipa, porta, ipz, portz, ip_proto)

      engine:update_flow( flowkey, 0,azbytes);
      engine:update_flow( flowkey, 1,zabytes);
      engine:update_flow( flowkey, 2,azpackets);
      engine:update_flow( flowkey, 3,zapackets);
      engine:update_flow( flowkey, 4,azpayload);
      engine:update_flow( flowkey, 5,zapayload);

      engine:set_flow_duration( flowkey, dur_secs);

      return true -- has more
            
    end,

  },

}


