--
-- tls-spy
--
-- TYPE:        FRONTEND SCRIPT

local PDURecord = require'pdurecord'
local TLSDissector = require'tls_dissect'

TrisulPlugin = { 

  id =  { name = "tls-spy"},

  onload  = function()
  	T.PDUStreamers = {} 
  end,

  -- reassembly_handler block
  reassembly_handler   = {

    -- we indicate to Trisul we want tls only (in trisul key format that is p-0016) 
    filter = function(engine, timestamp, flowkey) 
        return flowkey:id():match("p-01BB")  ~= nil 
    end,

	-- new flow
	onnewflow = function(engine, timestamp, flowkey) 
        if flowkey:id():match("p-01BB")  == nil then return; end
		local ins =   PDURecord.new(flowkey:id().."/0", TLSDissector.new() );
		local outs =   PDURecord.new(flowkey:id().."/1",  TLSDissector.new() ); 
		T.PDUStreamers[flowkey:id()] = { [0]=  ins, [1]= outs }
	end,

	-- run the PDU streamer , which will callback into the dissector 
    onpayload = function(engine, timestamp, flowkey, direction, seekpos, buffer) 

        if flowkey:id():match("p-01BB")  == nil then return; end
		local pdur = T.PDUStreamers[flowkey:id()][direction]
		pdur:push_chunk(seekpos, buffer:tostring())
    end,

  }
}
