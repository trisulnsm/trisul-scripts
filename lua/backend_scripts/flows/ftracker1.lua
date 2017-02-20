-- FlowTracker_PROD.lua
--
-- Only tracks UDP flows in subnet 10.10.22.0/24 
-- The metric returned is total_bytes. Therefore this tracker snapshots Top-K flows 
-- matching this rule.
--
TrisulPlugin = {

  id = {
    name = "FlowTracker-SUBNET1",
    description = "Only subnets a,b but excluding production apps",
  },


  flowtracker = {

    control = {
      name = "Subnet1-FT",
      description = "UDP flows from 10.10.22 net",
      bucketsize = 300,   -- 5 minutes streaming window 
      count = 100         -- 100 top flows meeting criteria 
    },


  -- return the metric you want to track associated with this flow
  -- you can examine all fields of the flow and use other factors
  -- to compute a number
  -- 
  -- return 0 or nil means this flow isnt of interest and not tracked 
  -- 
  getmetric = function(engine,f)

    if f:flow():protocol() == "11" and 
        f:flow():ipa_readable():match("^10.10.22") or f:flow():ipz_readable():match("^10.10.22") or
        then
          print("Metric for flow protocol ".. f:flow():protocol())
          return f:az_bytes() + f:za_bytes()
    end
  
  end,

  },


}

