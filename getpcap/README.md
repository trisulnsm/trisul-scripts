Work with PCAPS 
===============

The scripts in this directory describe how you can export Trisul data into PCAPs.

The three scripts here are

- getpackets.rb  : Downloads as a pcap file, all packets in a timeframe 
- getpackets2.rb : Explains how to save PCAPs remotely on your server instead of downloading
- daypcaps.rb    : For any month, save 1 PCAP per day neatly on the Trisul server

The main TRP message used in all these scenarios is
FILTERED_DATAGRAMS


### Save on server vs Download

The FILTERED_DATAGRAMS method allows you to download a PCAP or to keep it on the server.

Use the `disposition` field to indicate if you want to 
save the resulting PCAP on the server or if you want to download it to the 
client. This is useful for archival purposes.


#### Save on server location

If you choose to save the PCAPs on the server, they are stored in the `/tmp` directory under 
filenames that look like the following

````
$ ls -lrt /tmp
-rw------- 1 nsmdemo nsmdemo  41287806957 Feb 20 17:39 TFILT-15864-1392898081.pcap
-rw------- 1 nsmdemo nsmdemo  22274971817 Feb 20 17:40 TFILT-15864-1392898165.pcap
-rw------- 1 nsmdemo nsmdemo  51247056544 Feb 20 17:41 TFILT-15864-1392898218.pcap
````

The filename format is TFILE-{TRP Instance}-{Timestamp}.pcap

*Security Note* : Trisul does not allow you to control the filename or the location.


Sample run
-----

Get all packets between Sep 20 2013 an Sep 30 2013  

````
$ ruby getpackets.rb 192.168.1.8 12001
Enter PEM pass phrase: xxxxxx 
Number of bytes = 96594930
Number of pkts  = 138921
Hash            = a4015b399db9835435397843671e91674e2523b3
Saved on server = /tmp/TFILT-23890-1385038634.pcap
````


Code explanation
-----

### First we construct a TimeInterval message  to represent the desired interval

See http://trisul.org/docs/ref/trpprotomessages.html#timeinterval

You can ofcourse wrap this in a convenient helper method. 
We want to show you how to construct raw TRP objects.

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
			:disposition => TRP::PcapDisposition::SAVE_ON_SERVER,
			:filter_expression =>
				 TRP::FilteredDatagramRequest::ByFilterExpr.new( 
					:time_interval  => tint,
					:filter_expression  => "{9F5AD3A9-C74D-46D8-A8A8-DCDD773730BA}=0800" 
				)
      )


````



