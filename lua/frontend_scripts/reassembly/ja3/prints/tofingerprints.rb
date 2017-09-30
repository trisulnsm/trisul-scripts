require 'json'

#
# Converts JA3 format to Fingerprints found on https://github.com/LeeBrotherston/tls-fingerprinting
# skips fields that are not used by JA3 such as signature algorithms 
# 
raise "Usage : tofingerprints <ja3_file>" unless ARGV.length==1

File.foreach(ARGV.shift) do |line|
  next if line.chomp("\n").length==0
  out = {}

  ja3 = JSON.parse(line)
  ja3_str=ja3['ja3_str'].split(",")

  out["id"]=0
  out["desc"]=ja3['desc']
  out["record_tls_version"]="0x0301"
  out["tls_version"]="0x#{ja3_str[0].to_i.to_s(16).upcase.rjust(4,'0')}"
  out["ciphersuite_length"]="0x#{(ja3_str[1].split("-").length*2).to_i.to_s(16).upcase.rjust(4,'0')}"
  {1=>"ciphersuite",2=>"extensions",3=>"e_curves"}.each_pair do |idx,str|
    ja3_str[idx]=ja3_str[idx] || ""
    out[str]=ja3_str[idx].split("-").collect do | suite |
       "0x#{suite.to_i.to_s(16).upcase.rjust(4,'0')}"
    end.join(" ")
  end
  out["ec_point_fmt"]="0x#{ja3_str[4].to_i.to_s(16).upcase.rjust(2,'0')}"
  puts out.to_json
end
