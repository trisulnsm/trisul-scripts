-- LongLivedSSH-exclude hosts in white list 
--
-- The metric returned is duration. Therefore this tracker snapshots Top-K flows 
-- Use a whitelist pair to exlude known conversation endpts 
--
local dbg=require'debugger'
TrisulPlugin = {

  id = {
    name = "FlowTracker-SSHWHITELIST",
    description = "SSH by duration exclude whitelisted pairs ",
  },


  onload=function()
    T.whitelistpairs = {
        {"192.168.1.11", "138.68.45.27"}
    };

  end,


  flowtracker = {

    control = {
      name = "SSH-WHITELIST",
      description = "ssh duration whitelist",
      bucketsize = 300,   -- 5 minutes streaming window 
      count = 100         -- 100 top flows meeting criteria 
    },


  -- return the metric you want to track associated with this flow
  -- 
  -- return 0 or nil means this flow isnt of interest and not tracked 
  -- 
  getmetric = function(engine,f)

    local fid = f:flow()
    if fid:portz_readable() == "22" then

        for _, p in ipairs(T.whitelistpairs) do 
            local ip1 = p[1]
            local ip2 = p[2]

            if fid:ipa_readable() == ip1 and fid:ipz_readable() == ip2 or
               fid:ipz_readable() == ip1 and fid:ipa_readable() == ip2 then

                -- flow is whitelisted  ignore 

            else

                -- non whitelisted SSH flow , return duration as tracker metric
                local start_ts,last_ts = f:time_window()
                return last_ts - start_ts 
            end
        end 

    end
  
  end,

  },


}

