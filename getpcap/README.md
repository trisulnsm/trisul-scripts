Work with PCAPS 
===============

The scripts in this directory describe how you can export Trisul data into PCAPs.

The three scripts here are

- getpackets.rb  : Downloads as a pcap file, all packets in a timeframe 
- getpackets2.rb : Explains how to save PCAPs remotely on your server instead of downloading
- daypcaps.rb    : For any month, save 1 PCAP per day neatly on the Trisul server

The TRP message used in all these scenarios is [FILTERED_DATAGRAMS](http://trisul.org/docs/ref/trpprotomessages.html#filtereddatagram)


### Save on server vs Download

The [FILTERED_DATAGRAMS](http://trisul.org/docs/ref/trpprotomessages.html#filtereddatagram)  method allows you to download a PCAP or to keep it on the server.

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

The code steps are 

- Select a time interval
- Select a Trisul filter for the PCAP
- Save / Download the PCAP

Here is an explanation of the steps involved 

### First we construct a TimeInterval message 

See [TRP TimeInterval](http://trisul.org/docs/ref/trpprotomessages.html#timeinterval)

```` ruby
tint=TRP::TimeInterval.new ( {
   :from => TRP::Timestamp.new(:tv_sec => Time.new(2013,11,18,14,00).tv_sec),
   :to => TRP::Timestamp.new(:tv_sec => Time.new(2013,11,18,15,00).tv_sec)
})

````

### Second we use a filter expression

The [FILTERED DATAGRAMS](http://trisul.org/docs/ref/trpprotomessages.html#filtereddatagram ) message allows you to download PCAP files or to save on the server. 

You can get into packets using the following methods

1. By a filter expression ( eg, save all packets to Russia & China)
2. By a flow
3. By alerts
4. By resource (eg URL, DNS, SSL certs)

The filter expression is a special string in _Trisul Filter Format_ that looks like this

`{00990011-44BD-4C55-891A-77823D59161B}!us,ca`

The above string says all traffic involving IPs outside US and Canada.

Trisul Filter Format is documented [here](http://trisul.org/docs/ref/trisul_filter_format.html)


To retrieve all packets, we use the filter expression 
`"{9F5AD3A9-C74D-46D8-A8A8-DCDD773730BA}=0800"`
 
> The above expression translates to Get all packets where the LinkLayer is 0x0800 (this is IP Ethertype)

The funny looking string `{9F5AD3A9-C74D-46D8-A8A8-DCDD773730BA}` is called a GUID (Globally Unique ID). Trisul assigns a GUID for every counter group. The one above is for the Link Layer Counter group. 

Check out for more on GUIDs.
* Customize > Counters > Meters
or
* From the [list of well known GUIDS](http://trisul.org/docs/ref/guid.html)



### Third and final step - Get and save the packets

Construct the FilteredDatagrams command and get the packets for the timeframe and
filter  expression.

#### The request

```` ruby
req = TrisulRP::Protocol.mk_request(
	TRP::Message::Command::FILTERED_DATAGRAMS_REQUEST,
		:disposition => TRP::PcapDisposition::SAVE_ON_SERVER,
		:filter_expression =>
			 TRP::FilteredDatagramRequest::ByFilterExpr.new( 
				:time_interval  => tint,
				:filter_expression  => "{9F5AD3A9-C74D-46D8-A8A8-DCDD773730BA}=0800" )
      )

````

The code may look a bit nasty but once is actually straightfoward, We just set the disposition and the filter expression.  

#### The response

The main part of the code is what is inside the `fdr` object. That is the response from the server.
The [FILTERED_DATAGRAMS](http://trisul.org/docs/ref/trpprotomessages.html#filtereddatagram)  documentation explains the fields involved. 

```` ruby

TrisulRP::Protocol.get_response(conn,req) do |fdr|
  print "Number of bytes = #{fdr.num_bytes}\n"
  print "Number of pkts  = #{fdr.num_datagrams}\n"
  print "Hash            = #{fdr.sha1}\n"

  if fdr.disposition == TRP::PcapDisposition::DOWNLOAD
      File.open("filtered000.pcap","wb") do |f|
        f.write(fdr.contents)
      end
      print "Saved to filtered000.pcap\n"
  elsif fdr.disposition == TRP::PcapDisposition::SAVE_ON_SERVER
      print "Saved on server = #{fdr.path}\n"
  end
end

````

