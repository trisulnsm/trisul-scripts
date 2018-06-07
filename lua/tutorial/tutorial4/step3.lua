CSV=require'csv'
	local csv_path = "/tmp/urlhaus.txt" 

        -- we're going to load this table with Intel 
	T={}
	T.badurls = {} 

	-- loop every line in CSV 
	print("Processing CSV file "..csv_path) 
	local f = io.open(csv_path)
        local nitems = 0 
	for line in f:lines() do
		local fields={}
		for fld  in line:gmatch('"([^"]*)"') do
			fields[#fields+1]=fld
		end 

		print(fields[3]) 
	end
	print("Loaded "..nitems.." URLs from file") 
