TrisulPlugin = {

  id =  {
    name = "packet_storage",
    description = "how to control on flow level packet storage ",
  },


  packet_storage   = {

    -- 
    -- return 0 - 6 
    filter = function(engine, time, flow)
      if flow:portz_readable() == "22" then 
        print("blocking this.."..flow:id() )
        return 0
      else
        return -1   -- default processing is -1 
      end 
    end,

  },

}
