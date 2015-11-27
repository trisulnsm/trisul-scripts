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
require 'matrix'

# Check arguments
raise %q{


  itrp.rb - interactive TRP shell 

  Usage   : itrp.rb  trisul-zmq-endpt 
  Example : itrp.rb  tcp://192.168.1.8:5555 

} unless ARGV.length==1


HISTFILE=File.expand_path("~/.itrp_history")

# parameters 
zmq_endpt   = ARGV.shift


DEFAULT_PROMPT="iTRP> "

print("\n\niTRP Interactive TRP Shell for Trisul\n");



class Dispatches

	attr_reader :prompt 
	attr_reader :tmarr 
	attr_reader :cgguid 
	attr_reader :cgname 
	attr_reader :cgtype 

	def initialize(zmq)
		@zmq_endpt = zmq
		@prompt = DEFAULT_PROMPT

        if File.exist? HISTFILE
            File.readlines(HISTFILE).each do |l|
                Readline::HISTORY.push(l.chop)
            end
        end

		# get entire time window  
		@tmarr= TrisulRP::Protocol.get_available_time(@zmq_endpt)
		print("Connected to #{@zmq_endpt}\n");
		print("Available time window = #{tmarr[1]-tmarr[0]} seconds \n\n");

		list = ['cglist', 'set cg', 'set time', 'set rg', 'search', 'set ag', 'timeslices', 'set fts' , 'resolve' ]
		Readline.completion_proc = proc do |s| 
			case Readline.line_buffer()
				when /^set cg /;  match_cg(s)
				when /^set rg /;  match_rg(s)
				when /^set ag /;  match_ag(s)
				when /^set fts /;  match_fts(s)
				else ; list.grep( /^#{Regexp.escape(s)}/) 
			end
		end

	end



	def invoke(cmdline)

		case  cmdline.strip

		when "";  
		when "quit"; bye()
		when "up"; up()
		when "cglist"; cglist()
		when /set cg/; setcg(cmdline.strip)
		when /resolve/; resolve(cmdline.strip)
		when /toppers/; toppers(cmdline.strip)
		when "meters"; meters()
		when /set key/; setkey(cmdline.strip)
		when /traffic/; traffic(cmdline.strip)
		when /volume/; volume()
		when /refresh/; refresh()
		when /set rg/; setrg(cmdline.strip)
		when /set ag/; setag(cmdline.strip)
		when /set fts/; setfts(cmdline.strip)
        when /^search/; search(cmdline.strip)
        when /timeslices/; timeslices()
        when /delete/; delete(cmdline.strip)

		end

	end

	def up
		@cgguid=nil
		@cgname=nil
		@prompt=DEFAULT_PROMPT
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
					@cgname = group_detail.name 
					return
				 end
			  end
		end

        @cgtype = :counter 
	end



    def setrg(rgid)
        patt = rgid.scan(/set rg ({.*}) (.*$)/).flatten 
        @prompt = "iTRP (Resources / #{patt[1]})> "
        @cgguid = patt[0]
        @cgname = patt[1]
        @cgtype = :resources
    end 

    def setag(rgid)
        patt = rgid.scan(/set ag ({.*}) (.*$)/).flatten 
        @prompt = "iTRP (Alerts / #{patt[1]})> "
        @cgguid = patt[0]
        @cgname = patt[1]
        @cgtype = :alerts
    end 

    def setfts(rgid)
        patt = rgid.scan(/set fts ({.*}) (.*$)/).flatten 
        @prompt = "iTRP (FTS / #{patt[1]})> "
        @cgguid = patt[0]
        @cgname = patt[1]
        @cgtype = :fts
    end 

	def setkey(key)
		if @cgtype != :counter 
			puts("Err: need to do [set cg <countergroup>] first")
			return
		end

		patt = key.scan(/set key (.*)/).flatten.first 

		@cgkey=patt
		@prompt = "iTRP (#{@cgname}/#{@cgkey})> "

	end


    def resolve(keylist)

		patt = keylist.scan(/resolve (.*)/).flatten.first 

        patt.split(',')

		req =mk_request(TRP::Message::Command::KEY_LOOKUP_REQUEST,
						 :counter_group => @cgguid,
						 :keys  => patt.split(','))


        rows = []
		get_response_zmq(@zmq_endpt,req) do |resp|
            resp.keys.each do |k|
                rows << [ k.key, k.label, k.readable ]
            end
		end


		table = Terminal::Table.new( :headings => %w(Key  Label Readable ), :rows => rows)
		puts(table) 

    end


	def traffic(meterlist)

		patt = meterlist.scan(/traffic (.*)/).flatten.first 
		patt ||= "0"
		showmeters = patt.split(',').map(&:to_i)


		# meter names 
		req =mk_request(TRP::Message::Command::COUNTER_GROUP_INFO_REQUEST,
						 :counter_group => @cgguid,
						 :get_meter_info => true )

		colnames   = ["Timestamp"]
		get_response_zmq(@zmq_endpt,req) do |resp|
			  resp.group_details.each do |group_detail|
			  	group_detail.meters.each do |meter|
					colnames  <<  meter.name  
				end
			  end
		end


		req =TrisulRP::Protocol.mk_request(TRP::Message::Command::COUNTER_ITEM_REQUEST,
			 :counter_group => @cgguid,
			 :key => @cgkey,
			 :time_interval =>  mk_time_interval(@tmarr) )

		rows  = [] 

	
		TrisulRP::Protocol.get_response_zmq(@zmq_endpt,req) do |resp|
			  print "Counter Group = #{resp.stats.counter_group}\n"
			  print "Key           = #{resp.stats.key}\n"
			  
			  tseries  = {}
			  resp.stats.meters.each do |meter|
				meter.values.each do |val|
					tseries[ val.ts.tv_sec ] ||= []
					tseries[ val.ts.tv_sec ]  << val.val 
				end
			  end


			  rows = []
			  tseries.each do |ts,valarr|
			  	rows << [ ts, valarr ].flatten 
			  end

			  table = Terminal::Table.new(:headings => colnames,  :rows => rows )
			  puts(table) 
		end

	end


	# counter item with volumes_only flag set 
	def volume


		# meter names 
		req =mk_request(TRP::Message::Command::COUNTER_GROUP_INFO_REQUEST,
						 :counter_group => @cgguid,
						 :get_meter_info => true )

		colnames   = ["Timestamp"]
		get_response_zmq(@zmq_endpt,req) do |resp|
			  resp.group_details.each do |group_detail|
			  	group_detail.meters.each do |meter|
					colnames  <<  meter.name  
				end
			  end
		end


		req =TrisulRP::Protocol.mk_request(TRP::Message::Command::COUNTER_ITEM_REQUEST,
			 :counter_group => @cgguid,
			 :key => @cgkey,
			 :time_interval =>  mk_time_interval(@tmarr),
			 :volumes_only => 1 )

		rows  = [] 

	
		TrisulRP::Protocol.get_response_zmq(@zmq_endpt,req) do |resp|
			  print "Counter Group = #{resp.stats.counter_group}\n"
			  print "Key           = #{resp.stats.key}\n"
			  
			  tseries  = {}
			  resp.stats.meters.each do |meter|
				meter.values.each do |val|
					tseries[ val.ts.tv_sec ] ||= []
					tseries[ val.ts.tv_sec ]  << val.val 
				end
			  end


			  rows = []
			  tseries.each do |ts,valarr|
			  	rows << [ ts, valarr ].flatten 
			  end

			  table = Terminal::Table.new(:headings => colnames,  :rows => rows )
			  puts(table) 
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

	def match_rg(patt)

        [ '{4EF9DEB9-4332-4867-A667-6A30C5900E9E} HTTP URIs',
          '{D1E27FF0-6D66-4E57-BB91-99F76BB2143E} DNS Resources',
          '{5AEE3F0B-9304-44BE-BBD0-0467052CF468} SSL Certs',
        ].grep( /#{Regexp.escape(patt)}/i)  

    end

    def match_ag(patt)
        [  "{9AFD8C08-07EB-47E0-BF05-28B4A7AE8DC9} External IDS",
           "{5E97C3A3-41DB-4E34-92C3-87C904FAB83E} Blacklist activity",
           "{03AC6B72-FDB7-44c0-9B8C-7A1975C1C5BA} Threshold Crossing",
           "{18CE5961-38FF-4AEa-BAF8-2019F3A09063} System Alerts",
           "{0E7E367D-4455-4680-BC73-699D81B7CBE0} Threshold Band Alerts"
        ].grep( /#{Regexp.escape(patt)}/i)  
    end

    def match_fts(patt)
        [ "{28217924-E7A5-4523-993C-44B52758D5A8} HTTP Headers",
          "{9FEB8ADE-ADBB-49AD-BC68-C6A02F389C71} SSL Certs",
        ].grep( /#{Regexp.escape(patt)}/i)  
    end

	def bye
        File.open( HISTFILE, "w") do |h|
            Readline::HISTORY.to_a.uniq.each do |l|
                h.write(l + "\n" ) 
            end
        end

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
							  meter.name,
							  meter.description,
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


	def refresh
		# get entire time window  
		@tmarr= TrisulRP::Protocol.get_available_time(@zmq_endpt)
		print("Connected to #{@zmq_endpt}\n");
		print("Available time window is now = #{tmarr[1]-tmarr[0]} seconds \n\n");
	end


    def search(patt)
        
        case @cgtype
            when :resources ; search_resources(patt)
            when :alerts ; search_alerts(patt)
            when :fts ; search_fts(patt)
        end
    end

    def search_resources(patt)

		# meter names 
		req =mk_request(TRP::Message::Command::QUERY_RESOURCES_REQUEST,
						 :resource_group => @cgguid,
                         :time_interval =>  mk_time_interval(@tmarr),
						 :destination_port => 'p-0050'  )


        rows = [] 

		get_response_zmq(@zmq_endpt,req) do |resp|

            resp.resources.each do | res |

            rows << [ "#{res.resource_id}",
                      Time.at( res.time.tv_sec).to_s(),
                      res.source_ip.key,
                      res.source_port.key,
                      res.destination_ip.key,
                      res.destination_port.key,
                      wrap(res.uri,50),
                      wrap(res.userlabel,40)
            ]
            end

        end

		table = Terminal::Table.new( 
				:headings => %w(ID Time SourceIP Port DestIP Port URI Label ),
				:rows => rows)
		puts(table) 

    end

    def search_alerts(patt)

	   terms=patt.split(' ')
	   terms.shift

	   qparams = terms.inject({}) { |acc,t| acc.store( t.split('=')[0].to_sym,t.split('=')[1]);acc}

	   [:maxitems].each do |a|
	   	qparams[a] = qparams[a].to_i if qparams.key? a
	   end

	    p qparams 

		# meter names 
		req =mk_request(TRP::Message::Command::QUERY_ALERTS_REQUEST,
						 { 	:alert_group  => @cgguid,
                         	:time_interval =>  mk_time_interval(@tmarr),
						 }.merge(qparams))


        rows = [] 

		labelfmt = lambda do |fld|
			fld.label.empty? ? fld.key : fld.label
		end

		get_response_zmq(@zmq_endpt,req) do |resp|

            resp.alerts.each do | res |


            rows << [ "#{res.alert_id}",
                      Time.at( res.time.tv_sec).to_s(),
					  res.occurrances, 
                      labelfmt.call(res.source_ip),
                      labelfmt.call(res.source_port),
                      labelfmt.call(res.destination_ip),
                      labelfmt.call(res.destination_port),
                      res.sigid.key,
                      res.priority.key,
                      res.classification.key
            ]
            end

        end

		table = Terminal::Table.new( 
				:headings => %w(ID Time Count SourceIP Port DestIP Port SigID Prio Class ),
				:rows => rows)
		puts(table) 

    end

    def search_fts(patt)

	   terms=patt.split(' ')
	   terms.shift

	   qparams = terms.inject({}) { |acc,t| acc.store( t.split('=')[0].to_sym,t.split('=')[1]);acc}

	   [:maxitems].each do |a|
	   	qparams[a] = qparams[a].to_i if qparams.key? a
	   end

	    p qparams 

		# meter names 
		req =mk_request(TRP::Message::Command::QUERY_FTS_REQUEST,
						 { 	:fts_group  => @cgguid,
                         	:time_interval =>  mk_time_interval(@tmarr),
						 }.merge(qparams))


        rows = [] 

		get_response_zmq(@zmq_endpt,req) do |resp|

            resp.documents.each do | doc |
            p doc.docid 
                rows << [ doc.docid, 
                         doc.flows.inject("") do |acc,item|
                            acc  + item.key
                         end,
                         "doc.fullcontent", 
                       ]
            end

        end

		table = Terminal::Table.new( 
				:headings => %w(DocID Flows Content),
				:rows => rows)
		puts(table) 
    end

    def timeslices

		req =mk_request(TRP::Message::Command::TIMESLICES_REQUEST,{:context=>0}) 	

        rows = [] 

		get_response_zmq(@zmq_endpt,req) do |resp|
            resp.slices.each do | window |
                rows << [ Time.at(window.from.tv_sec), Time.at(window.to.tv_sec) ]
            end
        end 

		table = Terminal::Table.new( 
				:headings => %w(From  To),
				:rows => rows)
		puts(table) 

    end


    def delete(patt)

	   terms=patt.split(' ')
	   terms.shift

	   qparams = terms.inject({}) { |acc,t| acc.store( t.split('=')[0].to_sym,t.split('=')[1]);acc}

	   [:maxitems].each do |a|
	   	qparams[a] = qparams[a].to_i if qparams.key? a
	   end

	    p qparams 

		# meter names 
		req =mk_request(TRP::Message::Command::DELETE_ALERTS_REQUEST,
						 { 	:alert_group  => @cgguid,
                         	:time_interval =>  mk_time_interval(@tmarr),
						 }.merge(qparams))


		resp = get_response_zmq(@zmq_endpt,req)

        puts(resp.message)

    end

    def wrap(str,width)
      str.gsub!(/(.{1,#{width}})( +|$\n?)|(.{1,#{width}})/, "\\1\\3\n")
    end

end


dispatches = Dispatches.new(zmq_endpt)
while cmd = Readline.readline(dispatches.prompt, true)
    begin
        dispatches.invoke(cmd)
        Readline::HISTORY.push(cmd)
    rescue Exception => e 
        puts "Error " + e.message 
    end
end

