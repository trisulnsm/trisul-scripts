require 'json'
require 'digest/md5'

raise "Usage : toja3 <fingerprint file >" unless ARGV.length==2


JA3_FIELD_ORDER = %w(record_tls_version ciphersuite extensions e_curves ec_point_fmt) 

File.foreach(ARGV.shift) do |line|

	j = JSON.parse(line)


	jarr=JA3_FIELD_ORDER.collect do |f|
		v = j[f] || ""
		v.split(/\s+/).collect(&:hex).join('-')
	end

	ja3_str  = jarr.join(',')
	out = { :desc => j['desc'], :ja3_hash => Digest::MD5.hexdigest(ja3_str), :ja3_str => ja3_str }
	
	puts out.to_json
end 
