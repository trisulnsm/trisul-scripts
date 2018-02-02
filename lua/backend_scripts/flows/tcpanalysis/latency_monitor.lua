local dbg = require("debugger")
TrisulPlugin = {

  id =  {
    name = "sess group mon - letency",
    description = "Update cg for each flow latency"
  },

  countergroup = {
    control = {
      guid = "{E45623ED-744C-4053-1401-84C72EE49D3B}",
      name = "FLOW LATENCY",
      description = "Update flow latency for hosts",
      bucketsize = 60,
    },

    meters = {
      {  0, T.K.vartype.AVERAGE,  20, 20, "us", "Latency Internal",  "us"},
      {  1, T.K.vartype.AVERAGE,  20, 20, "us", "Latency External",  "us" },
      {  2, T.K.vartype.COUNTER,  20, 20, "pkts", "Retransmissions Internal",  "pkts"},
      {  3, T.K.vartype.COUNTER,  20, 20, "pkts", "Retransmissions External",  "pkts" },
    },  
  },


  sg_monitor  = {

    onflush = function(engine, newflow)
    local ipa = newflow:flow():ipa()
    local ipz = newflow:flow():ipz()
    local ipa_readable = newflow:flow():ipa_readable()
    local ipz_readable = newflow:flow():ipz_readable()

    if T.host:is_homenet(ipa_readable) then
      engine:update_counter("{E45623ED-744C-4053-1401-84C72EE49D3B}", ipa, 0, newflow:setup_rtt())
      engine:update_counter("{E45623ED-744C-4053-1401-84C72EE49D3B}", ipa, 2, newflow:retransmissions())
    else
      engine:update_counter("{E45623ED-744C-4053-1401-84C72EE49D3B}", ipa, 1, newflow:setup_rtt())
      engine:update_counter("{E45623ED-744C-4053-1401-84C72EE49D3B}", ipa, 3, newflow:retransmissions())
    end


    if T.host:is_homenet(ipz_readable) then
      engine:update_counter("{E45623ED-744C-4053-1401-84C72EE49D3B}", ipz, 0, newflow:setup_rtt())
      engine:update_counter("{E45623ED-744C-4053-1401-84C72EE49D3B}", ipz, 2, newflow:retransmissions())
    else
      engine:update_counter("{E45623ED-744C-4053-1401-84C72EE49D3B}", ipz, 1, newflow:setup_rtt())
      engine:update_counter("{E45623ED-744C-4053-1401-84C72EE49D3B}", ipz, 3, newflow:retransmissions())
    end


      print( newflow:flow():id())
    end,


  },

}
