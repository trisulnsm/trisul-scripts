# Trisul Remote Protocol TRP Demo script
#
# Full interactive shell app (Work in Progress) 
#
# ruby itrp.rb tcp://192.168.1.8:5555  
#
#
require 'trisulrp'
require 'readline'
require 'rb-readline'
require 'terminal-table'

# Check arguments
raise %q{


  itrp.rb - interactive TRP shell 

  Usage   : itrp.rb  trisul-zmq-endpt 
  Example : itrp.rb  tcp://192.168.1.8:5555 

} unless ARGV.length==1


# parameters 
zmq_endpt   = ARGV.shift



print("\n\niTRP Interactive TRP Shell for Trisul\n");



class Dispatches

	attr_reader :prompt 
	attr_reader :tmarr 
	attr_reader :cgguid 

	def initialize(zmq)
		@zmq_endpt = zmq
		@prompt = "iTRP> "

		# get entire time window  
		@tmarr= TrisulRP::Protocol.get_available_time(@zmq_endpt)
		print("Connected to #{@zmq_endpt}\n");
		print("Available time window = #{tmarr[1]-tmarr[0]} seconds \n\n");

		list = ['cglist', 'set cg', 'set time'  ]
		Readline.completion_proc = proc do |s| 
			case Readline.line_buffer()
				when /^set cg /;  match_cg(s)
				else ; list.grep( /^#{Regexp.escape(s)}/) 
			end
		end

	end



	def invoke(cmdline)

		case  cmdline.strip

		when "";  
		when "quit"; bye()
		when "cglist"; cglist()
		when /set cg/; setcg(cmdline.strip)
		when /toppers/; toppers(cmdline.strip)
		when "meters"; meters()

		end

	end


	def setcg(cgid)


		req =mk_request(TRP::Message::Command::COUNTER_GROUP_INFO_REQUEST)

		patt = cgid.scan(/set cg (.*)/).flatten.first 

		get_response_zmq(@zmq_endpt,req) do |resp|
			  resp.group_details.each do |group_detail|
				 if group_detail.name == patt 
				 	print("\nContext set to counter group [#{group_detail.name}] [#{group_detail.guid}]\n\n")
					@prompt = "iTRP (#{patt})> "
					@cgguid = group_detail.guid 
					return
				 end
			  end
		end


	end



	def cglist

		req =mk_request(TRP::Message::Command::COUNTER_GROUP_INFO_REQUEST)

		rows = []
		get_response_zmq(@zmq_endpt,req) do |resp|
			  resp.group_details.each do |group_detail|
			  	rows << [ group_detail.name,
						  group_detail.guid,
						  group_detail.bucket_size
				        ]
			  end
		end

		table = Terminal::Table.new :rows => rows
		puts(table) 
	end

	def match_cg(patt)

		req =mk_request(TRP::Message::Command::COUNTER_GROUP_INFO_REQUEST)

		cgdtls = []

		get_response_zmq(@zmq_endpt,req) do |resp|
			  resp.group_details.each do |group_detail|
				 cgdtls <<   group_detail.name
				 cgdtls <<   group_detail.guid
			  end
		end

		cgdtls.grep( /#{Regexp.escape(patt)}/)  

	end

	def bye
		exit(1)
	end

	def toppers(args)

		patt = args.scan(/toppers ([0-9]+)/).flatten.first 

		req =TrisulRP::Protocol.mk_request(TRP::Message::Command::COUNTER_GROUP_REQUEST,
			 :counter_group => @cgguid,
			 :meter => patt.to_i,
			 :resolve_keys => true,
			 :time_interval =>  mk_time_interval(@tmarr))

		TrisulRP::Protocol.get_response_zmq(@zmq_endpt,req) do |resp|
			  print "Counter Group = #{resp.counter_group}\n"
			  print "Meter = #{resp.meter}\n"

			  rows = [] 
			  resp.keys.each do |key|
			  		rows << [ key.key,
							  key.label,
							  key.metric ] 
			  end

			table = Terminal::Table.new :headings => ["Key", "Label", "Metric"], :rows => rows
			puts(table) 
		end

	end

	def meters

		req =mk_request(TRP::Message::Command::COUNTER_GROUP_INFO_REQUEST,
						 :counter_group => @cgguid,
						 :get_meter_info => true )

		rows = []
		get_response_zmq(@zmq_endpt,req) do |resp|
			  resp.group_details.each do |group_detail|
			  	group_detail.meters.each do |meter|
					rows << [ meter.id, 
							  meter.description,
							  meter.name,
							  meter.type,
							  meter.topcount,
							  meter.units] 
				end
			  end
		end

		table = Terminal::Table.new( 
				:headings => %w(MeterNo Name Description Type TopperCount Units),
				:rows => rows)

		puts(table) 

	end

end


dispatches = Dispatches.new(zmq_endpt)
while cmd = Readline.readline(dispatches.prompt, true)
	dispatches.invoke(cmd)
end

