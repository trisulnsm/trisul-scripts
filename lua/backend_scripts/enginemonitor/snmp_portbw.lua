-- .lua
--
-- snmp.lua
-- Generic SNMP Poller - turns Trisul into an SNMP Monitor 
--
-- Interfaces you want to poll are listed in Subscriber Interfaces 
-- WE use single community for all routers in simple version of this script 
-- 
-- // {9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a}
-- define_guid(<<name>>,
-- 0x9781db2c, 0xf78a, 0x4f7f, 0xa7, 0xe8, 0x2b, 0x1a, 0x9a, 0x7b, 0xe7, 0x1a);

local lsqlite3 = require 'lsqlite3'
local dbg = require'debugger'
-- local WEBTRISUL_DATABASE="/home/vivek/bldart/z01/webtrisul/db/webtrisul.db"
local WEBTRISUL_DATABASE="/usr/local/share/webtrisul/db/webtrisul.db"

function get_if_octets( agent, community, dir, port_ifindex)
  local oid = (dir == "in")  and 6 or 10 
  local h = io.popen("snmpget -v2c -c '"..community.."' "..agent.."  .1.3.6.1.2.1.31.1.1.1."..oid.."."..port_ifindex)
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

  countergroup = {
    control = {
      guid = "{9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a}",
      name = "SNMP-Interface",
      description = "Traffic using SNMP input ",
      bucketsize = 60,
    },

    meters = {
      {  0, T.K.vartype.DELTA_RATE_COUNTER,      20, "bytes", "Total BW",   "Bps" },
      {  1, T.K.vartype.DELTA_RATE_COUNTER,      20, "bytes", "In Octets",  "Bps" },
      {  2, T.K.vartype.DELTA_RATE_COUNTER,      20, "bytes", "Out Octets",  "Bps" },
    },
  },



  -- load polling targets from DB 
  onload = function()
    T.poll_targets = TrisulPlugin.load_poll_targets(WEBTRISUL_DATABASE)
    for k,v in pairs(T.poll_targets) do 
      print("ONLOAD: On Agent:".. k.." Targets="..table.concat(v,','))
    end 
  end,

  engine_monitor = {

    -- only do this from Engine 0. Run thru each port and send separat SNMP get 
    onbeginflush = function(engine, tv)

      if engine:instanceid() ~= "0" then return end 

      for agent,ports in pairs(T.poll_targets) do 
        for i,port in ipairs(ports) do 

          local val_in = get_if_octets(agent, T.default_community, "in", port)
          local val_out = get_if_octets(agent, T.default_community, "out", port) 

          engine:update_counter( "{9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a}",
             agent.."_"..port, 0, val_in + val_out   );

          engine:update_counter( "{9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a}",
             agent.."_"..port, 1, val_in  );

          engine:update_counter( "{9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a}",
             agent.."_"..port, 2, val_out  ); 

          T.log(T.K.loglevel.DEBUG, "SNMP vals tv="..(tv+10).."port="..port.." in="..val_in.." out="..val_out);
        end 
      end 

    end,

    -- every interval reload the map -
    onendflush = function(engine,tv)
      if engine:instanceid() ~= "0" then return end 

      T.poll_targets = TrisulPlugin.load_poll_targets(WEBTRISUL_DATABASE)
      for k,v in pairs(T.poll_targets) do 
        print("REFRESH EndFlush: On Agent:".. k.." Targets="..table.concat(v,','))
      end 

    end,

  },


  -- load polling targets from sqlite3 database 
  -- in this case webtrisul db 
  -- return { agent => [ifindex] } mappings 
  load_poll_targets = function(dbfile)

    T.log(T.K.loglevel.INFO, "Loading SNMP targets for polling from DB "..dbfile)

    local db=lsqlite3.open(dbfile)
    local stmt=db:prepare("SELECT SUBSCRIBER_NF_INTS FROM TRISUL_WEB_USERS");

    local allkeys={}
    while stmt:step()  do
      local v = stmt:get_values()
      allkeys[#allkeys+1]=v[1]
    end
    stmt:finalize()

    local agent_map = {}
    for i,v in ipairs(allkeys) do
      for agent, ifindex in  v:gmatch("([%d%.]+)_(%d+)") do 
        local oidarr = agent_map[agent] or {}
        oidarr[#oidarr+1]=ifindex
        agent_map[agent]=oidarr
      end
    end 


    -- community string     
    local stmt2=db:prepare("SELECT value FROM WEBTRISUL_OPTIONS where name='default_snmpv2_community';");
    if stmt2:step() then 
      T.default_community = stmt2:get_value(0)
    else 
      T.default_community = 'public'
    end 
    stmt2:finalize()

    db:close()

    return agent_map 

  end, 

}

