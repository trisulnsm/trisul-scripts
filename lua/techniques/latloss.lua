--
-- latencyloss.lua
-- 	
-- 	Uses message monitor framework to track TCP RTT 
-- 	estimate of latency and TCP Retransmissions estimate
-- 	of packet loss between subnets
--
--
TrisulPlugin = {

	id = {
		name = "Latency and Loss Monitor ",
		description = "Meters TCP Lat/Loss ",
		author = "Unleash",
		version_major = 1,
		version_minor = 0,
	},

	onload = function()
		T.host:log(T.K.loglevel.INFO, "Hi from latency and loss monitor sample ");
		targets = {};
		targets["C0.A83D"] = "MSCLOUD";
		targets["C0.A8CA"] = "AMAZONCLOUD";
		targets["C0.A889"] = "OWNCLOUD";
		default_target ="Internet";
	end,


	onunload = function ()
		T.host:log(T.K.loglevel.INFO, "Bye!")
	end,


	countergroup = {

		-- control section
		--   Id of the counter group 
		--   Use an online guid generator to create two unique guids
		control = {
			guid="{0f4281ed-5545-4bf2-94f2-c4027fbc9afa}",
			name = "Latency Loss",
			description = "Latency and Loss between branches ",
			bucketsize = 30,
		},

		-- meter section
		-- 	What we're trying to count 
		-- 	Here we count bytes and packets 
		meters = {
				{  0, T.K.vartype.AVERAGE, 	10,	"latency us", 	    "us" , 	     "us" },
				{  1, T.K.vartype.COUNTER, 	10,	"losspkts",	"losspkts" , "pkts" },
		},

	},


	messagemonitor   = {

		-- onflowmetric
		-- 	called on each loss/latency sample 
		onflowmetric = function(engine,flow, meterid, metervalue)
			local skey = flow:ipa():sub(0,5)..flow:ipz():sub(0,2)
			local dbkey = default_target;
			if targets[skey] then
				dbkey = targets[skey]
			end
			if meterid==6 then 
				engine:update_counter(TrisulPlugin.countergroup.control.guid, dbkey, 0, metervalue)
			elseif meterid==7 then
				engine:update_counter(TrisulPlugin.countergroup.control.guid, dbkey, 1, metervalue)
			end

		end,
	 },
}


