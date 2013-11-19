Get all packets for a specified timeframe 
=========================================

This script demonstrates the following

Get all packets between Sep 20 2013 an Sep 30 2013 

Steps
-----

### First we construct a TimeInterval message  to represent the desired interval

See http://trisul.org/docs/ref/trpprotomessages.html#timeinterval


````

tint=TRP::TimeInterval.new ( {
	:from => TRP::Timestamp.new(:tv_sec => Time.new(2013,11,18,14,00).tv_sec, :tv_usec=>0),
	:to => TRP::Timestamp.new(:tv_sec => Time.new(2013,11,18,15,00).tv_sec, :tv_usec=>0)
})

````


### Second we use a filter expression

The TRP command we are going to use to retrieve packets is FILTERED DATAGRAMS 
( http://trisul.org/docs/ref/trpprotomessages.html#filtereddatagram ). You can 
retrieve packets by filter expression, by flow, by resource (DNS,URL,TLS Cert,etc),
or by security alerts. We are going to use Filter Expression in this example.

The filter expression we are using is Get All IP Packets - this translates to 
get all packets where the LinkLayer counter group is 0x0800 (this is IP Ethertype)

You can get the GUID for the LinkLayer counter group from
* Customize > Counters > Meters
or
* From the list of well known GUIDS here 	http://trisul.org/docs/ref/guid.html


The expression is 
	"{9F5AD3A9-C74D-46D8-A8A8-DCDD773730BA}=0800" 


### Get and save the packets

Construct the FilteredDatagrams command and get the packets for the timeframe and
filter  expression.

````

req = TrisulRP::Protocol.mk_request(
			TRP::Message::Command::FILTERED_DATAGRAMS_REQUEST,
			:filter_expression =>
				 TRP::FilteredDatagramRequest::ByFilterExpr.new( 
					:time_interval  => tint,
					:filter_expression  => "{9F5AD3A9-C74D-46D8-A8A8-DCDD773730BA}=0800" 
				)
      )


````



