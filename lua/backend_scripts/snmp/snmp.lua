-- .lua
--
-- snmp.lua
-- Hooks on to the 1 minute ontimer() mechanism
-- to query SNMP and feed counters into Trisul 
--

-- // {9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a}
-- define_guid(<<name>>,
-- 0x9781db2c, 0xf78a, 0x4f7f, 0xa7, 0xe8, 0x2b, 0x1a, 0x9a, 0x7b, 0xe7, 0x1a);

function get_if_octets( dir, port_ifindex)
  local oid = (dir == "in")  and 6 or 10 
  local h = io.popen("snmpget -v2c -c 'cstring' 172.16.207.251  .1.3.6.1.2.1.31.1.1.1."..oid.."."..port_ifindex)
  local val = h:read("*a")
  print("val = "..val)
  h:close()
  local ctrval  = val:match("(%d+)%s*$")
  return tonumber(ctrval);

end

TrisulPlugin = {

  id = {
    name = "SNMP Interface",
    description = "Per Interface Stats : Key Agent:IfIndex ",
    author = "Unleash",
    version_major = 1,
    version_minor = 0,
  },


  onload = function()
  end,


  onunload = function()
  end,

  engine_monitor = {
    onbeginflush = function(engine, tv)
      
      local ports = { 1,2,3,4,23,24,625};

      for i,port in ipairs(ports) do 

      local val_in = get_if_octets("in", port)
      local val_out = get_if_octets("out", port) 

      engine:update_counter( "{9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a}",
             "if-"..port, 0, tv+10, val_in + val_out   );

      engine:update_counter( "{9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a}",
             "if-"..port, 1, tv+10, val_in  );

      engine:update_counter( "{9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a}",
             "if-"..port, 2, tv+10, val_out  ); 

      T.log(T.K.loglevel.DEBUG, "SNMP vals tv="..(tv+10).."port="..port.." in="..val_in.." out="..val_out);
      end 

    end
  },


}

