--
-- lanlflow.lua
--
--  custom input filter for Trisul to process the sample flow DB
--  published by lanl at ... http://csr.lanl.gov/data/cyber1/
--

local FI=require'flowimport'

-- string_to_ip() : the LANL dataset uses strings like C8938 to identify a host, 
-- but most Network tools need an IP address to work with. So we just hash32 the
-- string and use that not perfect because subnets arent maintained but works 
function  string_to_ip( strkey)
  local h = T.util.hash(strkey,32);
  return string.format("%d.%d.%d.%d",
             T.util.bitval32(h,31,8), T.util.bitval32(h,23,8),
             T.util.bitval32(h,15,8), T.util.bitval32(h,7,8));
end

-- string_to_port() : since we need a port number not a string 
function string_to_port( strkey)
  local portnum = T.util.hash(strkey,16);
  return string.format("%u", portnum)
end


TrisulPlugin = {

  id = {
    name = "LANL format custom input filter ",
    description = "Custom Filter ",
    author = "Unleash",
  },

  onload = function()
    T.loginfo("Loading flows.txt , onload() called ");
    print("Reading from flows file "..T.args) 
    datfile,errstr = io.open(T.args)
    if datfile==nil  then 
      T.logerror("Unable to open LANL CYBER input text file flows.txt : err="..errstr)
      return false
    end 
  end,


  onunload = function ()
    T.loginfo("OnUnload Custom Input filter LUA plugin, bye!");
  end,


  inputfilter  = {

    --  step get the next flow 
    --  read the next line from the file and do engine:updateXXX(..) to add metrics 
    step  = function(packet, engine)

      local nextline = datfile:read()

      -- check if end of file, then pipeline must shutdown 
      if nextline == nil or nextline:match("^%s*#") == 0 then
          return false
      end

      local fields = T.util.split(nextline,",")

      packet:set_timestamp(tonumber(fields[1]),1)

      -- ip source 
      local ts=tonumber(fields[1]) 
      local dur=tonumber(fields[2]) 
      local ipa=string_to_ip(   fields[3])
      local pra=string_to_port( fields[4])
      local ipz=string_to_ip(   fields[5])
      local prz=string_to_port( fields[6])
      local proto=string.format("%02X", tonumber(fields[7]));

      FI.process_flow( engine,  {
        first_timestamp=        ts,          -- unix epoch secs when flow first seen
        last_timestamp=         ts+dur,      -- unix epoch secs  when last seen 
        protocol=               proto,       -- ip protocol number 0-255
        source_ip=              ipa,         -- dotted ip format
        source_port=            pra,         -- source port number 0-65535
        destination_ip=         ipz,         -- dotted ip 
        destination_port=       prz,         -- source port number 0-65535
        bytes=                  fields[9],   -- octets, 
        packets=                fields[8],   -- packets 
      })

      -- print(nextline)
      return true -- has more
           
    end,
  },
}
