TrisulPlugin = {

  id =  {
    name = "sess group mon - prints flows",
    description = "writes to a file each new flow ",
  },

  onload = function()
    T.flowlogfile  = io.open("/tmp/flog."..T.contextid,"w")
    T.count=1;
  end,

  onunload=function()
    T.flowlogfile:close() 
  end,


  sg_monitor  = {

    session_guid = '{99A78737-4B41-4387-8F31-8077DB917336}',

    onnewflow = function(engine, newflow)
      T.flowlogfile:write( ""..T.count.."  "..newflow:flow():id().."\n");
      T.count = T.count+1
    end,

  },

}
