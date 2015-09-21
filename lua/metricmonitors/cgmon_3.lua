-- .lua
--
-- cgmon3.lua
-- Monitors counter group activity  - demonstrates tapping into Topper Flush 
--
--
TrisulPlugin = {

  id = {
    name = "CG Monitor ",
    description = "Example of monitoring counter group activity ",
    author = "Unleash",
    version_major = 1,
    version_minor = 0,
  },


  -- 
  -- Monitor attaches itself to a counter group and gets called for
  -- various events in the counter group lifecycle
  -- 
  cg_flush_monitor  = {

    counter_guid = "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",

	onbegintopperflush = function(dbengine,tvsec,meterid) 
		print(string.format("----------- Topper Flush [%d] Meter %d Time %d ", T.contextid, meterid, tvsec)) 
	end,

	ontopperflush = function(dbengine,key,metric) 
		print(string.format("ontopperflush  [%d]    %s  %d", T.contextid, key, metric)) 
	end,

	onendtopperflush = function(dbengine,metric) 

	end,

  },

}

