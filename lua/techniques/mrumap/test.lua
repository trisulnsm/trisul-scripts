local mrumap=require'mrumap'

local tst  = mrumap.new()
print(tst:get("hi"))

tst:put('oldest',1)
tst:put('secondoldest',1)
tst:put('oldestbutaccessedlater',1)

tst:put('deletedlater',1)
-- 
local function randstr() 
local chars={}
for i=1,10 do 
  table.insert(chars,string.char(math.random(97, 122)))
end
return table.concat(chars,"")
end 

-- insert about 
for i = 1, 25 do 
tst:put(randstr(),1)
end 

tst:get("oldestbutaccessedlater")

-- print in MRU order 
for k in tst:mru_iter()  do
print(k)
end
print("size="..tst:size())

-- pop the LRU item
tst:pop_back()

for k in tst:mru_iter()  do
print(k)
end

print("size="..tst:size())

-- delete 
tst:delete("deletedlater")

print("size="..tst:size())

-- roll back all to zero
while tst:pop_lru() do
--print("size="..tst:size())
end

print("size="..tst:size())

print("capacity="..tst:capacity())

