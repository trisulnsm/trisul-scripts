--
-- rocafile.lua :small test program 
--
-- PURPOSE:     check  PEM files for vulnerability
-- DESCRIPTION: usage  'luajit rocafile.lua example01.pem'
-- 


require'roca' 

T = {} 

TrisulPlugin.onload()

local pem_file = arg[1]
print("Checking  PEM file ".. pem_file)

-- run cmd  to extract the modulus from X509 
local pipein = io.popen( "openssl x509 -in ".. pem_file.."  -text")
local certchaindump= pipein:read("*a")

for m in certchaindump:gmatch("Modulus:([0-9a-fA-F:%s]*)Exponent") do

  local h = m:gsub("[:%s]","")
  print("modulus_hex="..h)

  if TrisulPlugin.is_vulnerable(h) then
    print("VULNERABLE...")
  else
    print("NOT VULNERABLE...")
  end

end

