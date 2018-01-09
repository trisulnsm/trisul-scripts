require 'json'
require 'csv'

raise "Usage : csv_toja3 <csv_fingerprint file >" unless ARGV.length==1


CSV_ORDER = {
	ja3_hash:0,
	description:1
}

p ARGV 

rows = CSV.foreach( ARGV[0], {headers:false,skip_lines:/^#/ }) do |row| 
	out = { :desc => row[0],
	        :ja3_hash => row[1].gsub(/"/,''),
			:ja3_string => ''}
	puts out.to_json


end

