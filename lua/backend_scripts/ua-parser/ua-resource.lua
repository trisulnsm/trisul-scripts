--
-- User-Agent resource  
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     Create a new resource group
-- DESCRIPTION: You can create your own resource groups for your specific case 
--
-- 
TrisulPlugin = { 

  id =  {
    name = "UA-Resource-Group",
  },

  -- resourcegroup  block - defines a new User-Agent resource Group 
  -- 
  resourcegroup  = {
    control = {
      guid = "{ED5CA168-1E17-44E0-7ABD-65E5C2DFAD21}", 
      name = "HTTP User-Agent",
    },
  },
}
