-- Simple trie for DNS
-- inspired from Kubernetes at https://raw.githubusercontent.com/kubernetes/contrib/master/ingress/controllers/nginx/lua/trie.lua
-- 

local _M = {}

local mt = {
    __index = _M
}


function _M.new()
    local t = { }
    return setmetatable(t, mt)
end

function _M.add(t, domain, source_intel  )

	-- reverse the domain and split by .
    local l = t
    for p in domain:reverse():gmatch("[a-zA-Z0-9\\-]+")  do
        if not l[p] then
            l[p] = {}
			l.__value=nil
        end
        l =  l[p]
    end
    l.__value = source_intel 
end

function _M.get(t, key)


    -- this may be nil
    local l = t
	

	-- reverse the domain and split by .
    local l = t
    for p in key:reverse():gmatch("[a-zA-Z\\-]+")  do
        if l[p] then
            l = l[p]
        else
            break
        end
    end

    -- may be nil
    return l.__value 
end

return _M
