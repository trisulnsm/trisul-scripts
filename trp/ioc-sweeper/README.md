Sweeping past traffic against OpenIOC Intel 
================================================

Trisul 3.0 sample script to demonstrate how you 
can consume an OpenIOC format feed and sweep past
traffic for matches.



The ruby script iocsweep.rb
------------------------------------

You also need to install Nokogiri to process the OpenIOC XML file 

````
gem install nokogiri
````


Locating Indicators of a particular type
----------------------------------------

A little bit of XML XPath magic lets you get a handle on the various
indicators. For example

````

# gets an array of IndicatorItems of type PortItem/remoteIP 
doc.xpath("//xmlns:IndicatorItem/xmlns:Context[@search='PortItem/remoteIP']")

# easy to extract the IPs contained inside the indicator..
doc.xpath("//xmlns:IndicatorItem/xmlns:Context[@search='PortItem/remoteIP']")
           .collect do |a|
		      a.at_xpath("//xmlns:Content").text
end

````

