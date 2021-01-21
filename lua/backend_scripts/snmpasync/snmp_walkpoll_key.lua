-- .lua
--
-- snmp_walkpoll.lua
-- Update Trisul Counters based on SNMP walk 
--
-- GUID  of new counter group SNMP-Interface = {9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a} 

local lsqlite3 = require 'lsqlite3'
local JSON=require'JSON'
local dbg = require("debugger")

local SNMP_DATABASE="/usr/local/var/lib/trisul-hub/domain0/hub0/context0/meters/persist/c-2314BB8E-2BCC-4B86-8AA2-677E5554C0FE.SQT"


TrisulPlugin = {

  request_async_workers=4,

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
    T.poll_targets =  nil
  end,

  engine_monitor = {

    -- every interval reload the map -
    onendflush = function(engine,tv)

	  print("---- ENDFLUSH FROM PAST CYCLE    --"..T.async:pending_items())
      local new_targets =  TrisulPlugin.load_poll_targets(engine:instanceid(), SNMP_DATABASE)
      if new_targets ~= nil then
        T.poll_targets = TrisulPlugin.load_poll_targets(engine:instanceid(),SNMP_DATABASE)
      end
	  print("---- ENDFLUSH ASYNC PENDING ITEMS--"..T.async:pending_items())

	  TrisulPlugin.engine_monitor.schedule_polls(engine,tv)
    end,

    -- schedule polls 
    schedule_polls  = function(engine, tv)
     
      if T.poll_targets == nil then return end

	  local async_task = require'async_tasks'

      for _,agent in ipairs(T.poll_targets) do 

		async_task.data =JSON:encode(agent)

        T.async:schedule ( async_task) 

      end
    end,

  },


  -- load polling targets from sqlite3 database 
  -- in this case webtrisul db 
  -- return { agent => [ifindex] } mappings 
  load_poll_targets = function(engine_id, dbfile)

    T.log(T.K.loglevel.INFO, "Loading SNMP targets for polling from DB "..dbfile)


    local status,db=pcall(lsqlite3.open,dbfile);
    if not status then
      T.logerror("Error open lsqlite3 err="..db)
      return nil
    end 


    local status, stmt=pcall(db.prepare, db,  "SELECT * from KEY_ATTRIBUTES where ATTR_NAME like 'snmp.%'");
    if not status then
      db:close() 
      T.logerror("Error prepare lsqlite3 err="..stmt)
      return nil
    end 
    local targets = {} 
    local snmp_attributes={}


    local ok, stepret = pcall(stmt.step, stmt) 
    while stepret  do
      local v = stmt:get_values()
      if snmp_attributes[v[1]] == nil then
        snmp_attributes[v[1]]={}
      end
      snmp_attributes[v[1]][v[2]]=v[3]
      ok, stepret = pcall(stmt.step, stmt) 
    end
    for ipkey,snmp in pairs(snmp_attributes) do
      if T.util.hash( snmp["snmp.ip"],1) == tonumber(engine_id) then 
	  	if snmp['snmp.community'] ~= nil and #snmp['snmp.community'] > 0  then 
			targets[ #targets + 1] = { agent_ip = snmp["snmp.ip"], agent_community = snmp["snmp.community"], agent_version = snmp["snmp.version"] } 
			T.log(T.K.loglevel.INFO, "LOADED  ip="..snmp["snmp.ip"].." version"..snmp["snmp.version"].." comm=".. snmp["snmp.community"])
			--print("LOADED  ip="..snmp["snmp.ip"].." version="..snmp["snmp.version"].." comm=".. snmp["snmp.community"])
		else
			T.log(T.K.loglevel.INFO, "NULL community , skipping deleted SNMP agent  ip="..snmp["snmp.ip"].." version="..snmp["snmp.version"])
			print("NULL    community , skipping deleted SNMP agent  ip="..snmp["snmp.ip"].." version="..snmp["snmp.version"])
		end
      else
        T.log(T.K.loglevel.INFO, "SKIPPED ip="..snmp["snmp.ip"].." version"..snmp["snmp.version"].." comm=".. snmp["snmp.community"])
        print("SKIPPED ip="..snmp["snmp.ip"].." version="..snmp["snmp.version"].." comm=".. snmp["snmp.community"])
      end 
    end
    stmt:finalize()
    db:close()
    return targets

  end, 

}

