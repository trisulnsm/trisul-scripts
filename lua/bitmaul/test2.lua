local PDURec = require'pdurecord'



local pdu1 =  PDURec.new("hi0")
print(pdu1)

pdu1:push_chunk(1,"ABCDEF")
print(pdu1)

pdu1:push_chunk(1,"ABCDEF")
print(pdu1)

pdu1:push_chunk(4,"BCDEFG")
print(pdu1)

pdu1:push_chunk(4,"BCDEFG")
print(pdu1)

pdu1:push_chunk(5,"BEFG")
print(pdu1)

pdu1:push_chunk(8,"12----n933483843843")
print(pdu1)


local v = pdu1:want_to_pattern( "----")
print(v)
print(pdu1)

local v = pdu1:want_next( 40)
print(v)

pdu1:push_chunk(12,"12++++n933483843843")
print(pdu1)

local v = pdu1:want_next( 40)
print(v)

pdu1:push_chunk(20,"12++++n933483843843")
print(pdu1)

local v = pdu1:want_next( 40)
print(v)

pdu1:push_chunk(30,"12++++n933483843843")
print(pdu1)

local v = pdu1:want_next( 40)
print(v)

pdu1:push_chunk(38,"12++++n933483843843")
print(pdu1)

local v = pdu1:want_next( 40)
print(v)
print(pdu1)

pdu1:push_chunk(43,"88++++n933483843843")
print(pdu1)
