--
-- new_resource_group.lua skeleton
-- {7B431613-9291-49BF-F8D3-73578A445310}
-- DEFINE_GUID(GUID_xxx,0x7B431613,0x9291,0x49BF,0xF8,0xD3,0x73,0x57,0x8A,0x44,0x53,0x10);
-- 
TrisulPlugin = { 

  id =  {
    name = "Raw Syslogs",
    description = "raw syslogs ", 
  },


  -- resourcegroup  block
  -- 
  resourcegroup  = {

    -- table control 
    -- WHEN CALLED: specify details of your new resource  group
    --              you can use 'trisulctl_probe testbench guid' to get a new GUID
    control = {
      guid = "{7B431613-9291-49BF-F8D3-73578A445310}",
      name = "Raw Syslogs",
      description = "Raw text syslogs",
    },

  },
}
