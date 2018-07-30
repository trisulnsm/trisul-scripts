require 'faraday'
require 'json'
require 'leveldb'


raise "Usage:  otx2leveldb.rb  apikey  output-leveldb-path"  unless ARGV.length == 2

apikey   = ARGV[0]
outputdb = ARGV[1]
server   = "https://otx.alienvault.com"


conn = Faraday.new(:url => server) do |faraday|
  faraday.request  :url_encoded             # form-encode POST params
  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
end


# validation  - check API key validity 
url= "/api/v1/users/me"
response = conn.get do |req|
  req.url url
  req.headers['X-OTX-API-KEY'] = apikey
end

unless JSON.parse(response.body)["user_id"]
  print("Invalid api key response from #{server} :  #{apikey}\n")
  return
end


# download all the subscribed pulses 
response = conn.get do |req|
  req.url  "/api/v1/pulses/subscribed"
  req.headers['X-OTX-API-KEY'] = apikey
  #req.params={modified_since:Time.now-86400}
end
rows = []
responses = JSON.parse(response.body)
results = responses["results"]


# write to level DB key => JSON of alienvault JSON pulse 
db = LevelDB::DB.new(outputdb) 
results.each do |data|
  pulse = {pulse_id:data["id"],pulse_name:data["name"],tlp:data["tlp"]}
  data["indicators"].each_with_index do |i,idx|
    db.put i.delete("indicator"),pulse.merge(i).to_json()
  end
end 


# Dump keys to console 
db.each do |k,v|
  print("#{k}\n")
end

db.close() 
