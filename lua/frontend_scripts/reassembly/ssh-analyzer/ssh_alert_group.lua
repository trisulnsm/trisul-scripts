--
-- SSH Related Alerts 
-- 
--    we alert when 
-- 		1. non-ETM ciphers are used 
-- 		2. on successful login 
-- 		3. on successful login with keystroke 
--      3. ssh v1 is used
--		4. on keystroke on port forward SSH 
-- 
--    this file just creates the new alert group, the actual alerting 
--    happens in ssh_dissect.lua
-- 
TrisulPlugin = { 

  id =  {
    name = "SSH Alerts",
    description = "On ssh events", 
    author = "Trisul", 
  },


  alertgroup  = {

    -- WHEN CALLED: specify details of your new alert  group
    --              you can use 'trisulctl_probe testbench guid' to get a new GUID
    control = {
      guid = "{E713ED84-F2D9-4469-148C-00C119992926}",
      name = "SSH-Alerts",
      description = "SSH shell login events",
    },

  },
}
