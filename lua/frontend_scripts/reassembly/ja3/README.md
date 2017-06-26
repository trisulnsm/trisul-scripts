IOC based on Client Hello fingerprinting 
======================

An experimental Trisul plugin for collecting client hello fingerprints. 

This method is an implementation of https://github.com/salesforce/ja3  

Change to original  - handle GREASE 
------
I deployed this script on a live Trisul system and noticed a unexpectedly huge number of hashes streaming by.  I dug a bit deeper and found that  Google Chrome was the culprit, they were randomly inserting reserved values of TLS Ciphers, Extensions, and EllipticCurve  in the Client Hello.  *Why on earth would they do that !!*  Well it turns out there is a Draft-RFC called [GREASE](https://tools.ietf.org/html/draft-davidben-tls-grease-01) 
that explains this behavior.

I added a bit of code to replace all GREASE values in the ja3 hash fields with 0 and re-calculate the MD5. The noise immediately died down and the signatures are now proving to be interesting. I might publish a set of fingerprints once we have enough data. 

What jahash.lua does 
--------------

It does 2 things.

1. A *reassembly_handler*  -- parses Client Hello and pulls out the fields required for the ja3 hash.  The chunk of LuaJIT code at the beginning is a neat way to safely parse packets in LUA.   [API Docs](https://www.trisul.org/docs/lua/reassembly.html)

2. A *resource_group*  -- creates a new type of resource to which we add discovered hashes.  [API Docs](https://www.trisul.org/docs/lua/resource_group.html) 


Code
----

The  relevant piece of code that removes the GREASE values 

````
	  -- kick out GREASE extensions  from all tables (see draft RFC) 
	  for _, ja3f_tbl in ipairs( { ja3f.Cipher, ja3f.SSLExtension, ja3f.EllipticCurve} ) do 
		  for i, v in ipairs(ja3f_tbl) do 
			if  GREASE_tbl[v] then ja3f_tbl[i]=0;  end
		  end
	  end 

````

