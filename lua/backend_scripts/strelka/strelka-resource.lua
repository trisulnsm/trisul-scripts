--
-- strelka_resource : A new resource type to hold the Strelka JSON results document 
--
-- 
TrisulPlugin = { 

  id =  {
    name = "Strelka Scan",
    description = "Scan results ",
  },

  -- resourcegroup  block
  -- 
  resourcegroup  = {
    control = {
      guid = "{8A3E3EE5-0194-4B3C-9400-39BE9E7F7A11}",
      name = "Strelka Scan",
      description = "Output JSON document from Strelka scan",
    },
  },
}
