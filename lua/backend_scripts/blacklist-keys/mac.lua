--
-- mac.lua
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Use static blacklist for MAC addresses
-- DESCRIPTION: Alert when a MAC address from blacklist shows up 
-- 

Blacklist = require'shadowhammer-blacklist' 


TrisulPlugin = { 

  id =  {
    name = "MAC blacklist",
    description = "plugin to MAC counter group and watch for onnewkey", 
  },

  -- cg_monitor block
  -- 
  cg_monitor  = {

    -- monitor counter group MAC 
    counter_guid = "{4B09BD22-3B99-40FC-8215-94A430EA0A35}",

    -- As soon as a new key is seen , new keys repeat every X hours 
    onnewkey = function(engine, timestamp, key)

	  local m = Blacklist[key]
      if m then 

        T.logdebug("Found MAC in user specified Blacklist "..key)
        print("Found MAC in user specified Blacklist "..key)

		engine:add_alert("{B5F1DECB-51D5-4395-B71B-6FA730B772D9}" ,             
								nil,"FireHOL",2,"Found alert in FireHOL range "..tostring(m))
      end
    end,

  },
}

