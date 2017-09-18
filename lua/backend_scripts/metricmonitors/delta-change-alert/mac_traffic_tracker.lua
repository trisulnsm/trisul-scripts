--
-- MAC Monitor and Alerter  
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Monitors traffic from certain MACs and alert when you see UP or DOWN 50% 
-- DESCRIPTION: Use case in real life - FIN TECH Multicast feed liveness 
-- 
-- 
-- 

local dbg=require'debugger'
TrisulPlugin = { 

  -- MAC Tracker and Alerter 
  id =  {
    name = "MAC Tracker",
    description = "Monitors custom MACs ",   -- optional
  },

  mac_table = {
	["00:1C:C0:B9:B9:10"] = {delta=0.5, alert_str="SYSTEMUNDER_TEST_77" , last_val=0, last_val_tm=0} ,
	["00:1B:57:41:71:75"] = {delta=0.5, alert_str="SEMINDIA" , last_val=0, last_val_tm=0} ,
  },

  onload = function()
    -- your code 
  end,

  onunload = function()
    -- your code 
  end,

  cg_monitor  = {

    counter_guid = "{4B09BD22-3B99-40FC-8215-94A430EA0A35}",

    onflush = function(engine, timestamp,key, metrics) 

	local ctl  = TrisulPlugin.mac_table[key]
	if not ctl then return end


	-- dbg()

	local metric_total  = metrics[1] + metrics[2]

	if ctl.last_val_tm > 0 and 
	   math.abs(metric_total - ctl.last_val)  > ctl.last_val  * ctl.delta then
		engine:add_alert_tca( "{A8BE56E2-8F30-4854-013B-0CB13054F420}",
				      1,
				      "FIRED",
				      ctl.alert_str.." is now ".. metric_total .." over last interval"..ctl.last_val);
		print( "FIRE___> " .. ctl.alert_str.." is now ".. metric_total .." over last interval"..ctl.last_val);
	end 


	ctl.last_val = metric_total
	ctl.last_val_tm = timestamp

	print("last_val = "..ctl.last_val)
	print("last_val_tm = "..ctl.last_val_tm)
    end,

    
    -- this is the key if Traffic stops how to alert! 
    onmetronome = function(engine, timestamp, tick_count, tick_interval )
	for _,ctl in pairs(TrisulPlugin.mac_table) do
		if timestamp - ctl.last_val_tm  > 120  and ctl.last_val > 0 then
			engine:add_alert_tca( "{A8BE56E2-8F30-4854-013B-0CB13054F420}",
					      1,
					      "FIRED",
					      ctl.alert_str.." is now 0000 , last interval"..ctl.last_val);
		        print(ctl.alert_str.." is now 0000 , last interval"..ctl.last_val);
			ctl.last_val=0
			ctl.last_val_tm=timestamp
		end 
	end 
	
    end,

  },

  -- Usage Alert - a new custom alert 
  -- 
  alertgroup  = {

    control = {
      guid = "{A8BE56E2-8F30-4854-013B-0CB13054F420}",
      name = "Trading Traffic Alert",
      description = "When Trade traffic drops or starts ",
    },

  },

}
