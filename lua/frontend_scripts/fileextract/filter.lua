-- filter.lua 
--
--  Filter out common text based file types 
--
--  Demonstrates 
--  ------------
--  1. Use of filter(..) to only save text/html content 
--
--  2. We dont do anything else, so this script only impacts what files get 
--	   the built in MD5 file hashing
--
TrisulPlugin = {

  id = {
    name = "filter built in MD5 hashing",
    description = "Only allow some Content-Type to be extracted and MD5 generated ",
  },



  -- Monitor attaches itself to file extraction module(s)
  --
  filex_monitor  = {

    -- 
    -- filter : Check the response content type and decide 
	--   If the response header matches the regex '(application|javascript)'
	-- 	 then process the file and do its MD5, else skip
    --
    filter = function( engine,  timestamp, flowkey, header)

        if header:is_response() then 
            if header:match_value("Content-Type", "(application|javascript)") then  
                return true
            else
                return false
            end
        end
        return true
    end,
 }

}

