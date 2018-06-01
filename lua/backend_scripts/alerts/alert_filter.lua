--
-- alert_filter.lua skeleton
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Listen to alert activity 
-- DESCRIPTION: Process streaming alerts as they come in and also plug into 
--              the "flush" activity when alerts are forwarded to the 
--              Hub nodes for storage. 
-- 

TrisulPlugin = { 

 -- the ID block, you can skip the fields marked 'optional '
 -- 
 id =  {
    name = " Badfellas alert group Monitor",
    description = "Process alert events in the badfellas alert group ", -- optional
    author = "Unleash",                                           -- optional
    version_major = 1,                                            -- optional 
    version_minor = 0,                                            -- optional 
  },

  -- WHEN CALLED : your LUA script is loaded into Trisul 
  onload = function()
  end,

  -- WHEN CALLED : your LUA script is unloaded  / detached from Trisul 
  onunload = function()
  end,

  -- the alert_monitor block
  -- you only need to define the functions you need 
  alert_monitor  = {


    -- which alert group do you want to monitor
    -- each alert group is identified by a GUID login as admin > profile > Alert groups to view 
    alert_guid = '{5E97C3A3-41DB-4E34-92C3-87C904FAB83E}',






    -- WHEN CALLED: when each alert is flushed to the hub node (default every 60 secs)
    -- return false if you dont want to save this alert, true to save 
    flushfilter = function(engine, alert) 
      -- Block the ALIENVAULT alert type
      if alert:sigid() == "ALIENVAULT" then
        return false;
      else    
        return true;
      end
    end,


  },

}
