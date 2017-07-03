--
-- ssh-spy
--
-- TYPE:        FRONTEND SCRIPT

local PDURecord = require'pdurecord'
local SSHDissector = require'ssh_dissect'

TrisulPlugin = { 

  id =  { name = "ssh-spy", description = "SSH KE/Crypto/HMAC tracker", },

  onload  = function()
  	T.PDUStreamers = {} 
  end,

  -- reassembly_handler block
  reassembly_handler   = {

    -- we indicate to Trisul we want ssh only (in trisul key format that is p-0016) 
    filter = function(engine, timestamp, flowkey) 
        return flowkey:id():match("p-0016")  ~= nil 
    end,

	-- new flow
	onnewflow = function(engine, timestamp, flowkey) 
        if flowkey:id():match("p-0016")  == nil then return; end

		local ssh1, ssh2 = SSHDissector.new_pair()
		local ins =   PDURecord.new(flowkey:id().."/0",  ssh1)
		local outs =   PDURecord.new(flowkey:id().."/1", ssh2)
		T.PDUStreamers[flowkey:id()] = { [0]=  ins, [1]= outs }
	end,

	-- run the PDU streamer , which will callback into the dissector 
    onpayload = function(engine, timestamp, flowkey, direction, seekpos, buffer) 

        if flowkey:id():match("p-0016")  == nil then return; end
		local pdur = T.PDUStreamers[flowkey:id()][direction]
		pdur:push_chunk(seekpos, buffer:tostring())
    end,

  }
}
