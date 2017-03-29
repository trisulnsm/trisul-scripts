--
-- skip_ssh.lua 
-- 
-- [FASTPATH]
--
-- Do not store SSH (Port 22) packets  ( a near total waste of your disk $$$ in NSM applications)
-- 
TrisulPlugin = {

  id =  {
    name = "packet_storage",
    description = "how to control on flow level packet storage ",
  },


  packet_storage   = {

    -- look at flow tuples and decide 
    -- return 0 - 6 
	--
    filter = function(engine, time, flow)

      if flow:portz_readable() == "22" then 
        -- print("blocking this.."..flow:id() )
        return 0	-- return 0 to say -> 'I vote "Dont Store Packets for this Flow" 
      else
        return -1   -- return -1 to say -> 'I have no opinion, do what you normally would do' 
      end 
    end,
  },

}
