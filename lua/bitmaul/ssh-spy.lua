--
-- ssh-spy
--
-- Port Independent  SSH- detector
-- 
-- TYPE:        FRONTEND SCRIPT

local PDURecord = require'pdurecord'
local SSHDissector = require'ssh_dissect'

TrisulPlugin = { 

  id =  { name = "ssh-spy", description = "SSH KE/Crypto/HMAC tracker", },

  onload  = function()
	T.Pimpl = {}  -- on non standard ports 
  end,

  -- reassembly_handler block
  reassembly_handler   = {

	-- run the PDU streamer , which will callback into the dissector 
    onpayload = function(engine, timestamp, flowkey, direction, seekpos, buffer) 

		local ctl = T.Pimpl[flowkey:id()] 
		if not ctl then 
			if seekpos==0 and not buffer:tostring():find("^SSH-2.0") then
				local ssh1, ssh2 = SSHDissector.new_pair()
				local ins =   PDURecord.new(flowkey:id().."/0",  ssh1)
				local outs =   PDURecord.new(flowkey:id().."/1", ssh2)
				ctl  = { [0]=  ins, [1]= outs }
				T.Pimpl[flowkey:id()] =  ctl
			else 
				engine:disable_reassembly(flowkey:id())
				return
			end
		end
		local pdur = ctl[direction]
		pdur:push_chunk(seekpos, buffer:tostring())
    end,

	-- 
	onterminateflow  = function(engine, timestamp, flowkey)
		T.Pimpl[flowkey:id()]  = nil 
	end,

  }
}
