--
-- Alert on Dynamic DNS 
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Watches DNS resource stream and does suffix matching against known partial doms
--        requires 
--        1. trie.lua (basic trie to store DNS names) 
--        2. dynamic-dns.txt (a basic feed file) 
-- 
TrisulPlugin = { 

  -- id block
  --
  id =  {
    name = "Alert on Dyndns",
    description = "Alert on dyndns and numeric only names", 
  },

  -- Load the feed here 
  onload = function()

    T.dnstrie  = require'trie'

    -- load the intel 
    -- each line in this format -- domain # provider (3d-game.com #dtdns.com)
    local line_number  = 1 
    for line in io.lines("dynamic-dns.txt") do 
      local domain_name, provider =  line:match("%s*(%S+)%s*#(.*)")
      T.dnstrie:add(domain_name, provider .. " intel source line ".. line_number );
      line_number = line_number + 1
    end

    T.log("Loaded ".. line_number .. " dynamic domains from intel file ");

  end,

  -- resource_monitor block 
  --
  resource_monitor  = {

  -- DNS resources 
    resource_guid = '{D1E27FF0-6D66-4E57-BB91-99F76BB2143E}',

    -- WHEN CALLED : a new resource is seen (immediately)
    onnewresource  = function(engine, resource )
      local hit = T.dnstrie:get( resource:uri())
      if hit then 
        T.log("Dynamic DNS hit for ".. resource:uri() ) 
        engine:add_alert( "{F69C2462-ECEA-45B8-B1CB-F90342D37A4F}",
                  resource:flow():id(),
                  hit,
                  1,
                  "Request for dyndns resource "..resource:uri())
      end
    end,

  },

}
