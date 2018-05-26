local SweepBuf = require'sweepbuf'

local sb1 =  SweepBuf.new("abcdefghijklmnopqrstuvwzyz\r\n")
print(sb1)


local sb2 =  SweepBuf.new("0123456789")
print(sb2)


local sb3 =  sb1 + sb2 
print(sb3)


if sb1 <= sb2 then
	print("SB1 LESER")
end 

if sb2 <= sb1 then
	print("SB2 LESER")
end


