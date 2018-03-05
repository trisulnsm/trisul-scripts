local YAML=require'tinyyaml'
local inspect=require'inspect' 

local input_file = io.open("t.yaml","r")
local contents = input_file:read("*a")

print( contents )


local doc = YAML.parse(contents) 
print(inspect(doc) )

for k,v in pairs(doc['user_agent_parsers'])  do 

 	inspect(v) 
	print('----')
	print(v['regex'])
	print(v['family_replacement'])


end
