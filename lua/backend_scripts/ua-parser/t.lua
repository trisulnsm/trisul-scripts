local YAML=require'tinyyaml'
local inspect=require'inspect' 

local input_file = io.open("t.yaml","r")
local contents = input_file:read("*a")

print( contents )

local test_str = "Mozilla/4.0 (compatible; GoogleToolbar 4.0.1601.4978-big; Windows XP 5.1; MSIE 6.0.2900.2180)"


local doc = YAML.parse(contents) 
print(inspect(doc) )

for k,v in pairs(doc['user_agent_parsers'])  do 

 	inspect(v) 
	print('----')
	print(v['regex'])
	print(v['family_replacement'])


end
