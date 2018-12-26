IOC based on Client Hello fingerprinting 
======================

> ## Moved 
> **JA3 Prints Database moved to new repository** [trisulnsm/ja3prints](https://github.com/trisulnsm/ja3prints)
> Please submit any pull requests there. Thanks !  

An experimental Trisul plugin for collecting client hello fingerprints.  

>  Requires the sweepbuf.lua buffer parsing library https://github.com/trisulnsm/bitmaul

This method is an implementation of https://github.com/salesforce/ja3  

Change to original  - handle GREASE 
------
I deployed this script on a live Trisul system and noticed a unexpectedly huge number of hashes streaming by.  I dug a bit deeper and found that  Google Chrome was the culprit, they were randomly inserting reserved values of TLS Ciphers, Extensions, and EllipticCurve  in the Client Hello.  *Why on earth would they do that !!*  Well it turns out there is a Draft-RFC called [GREASE](https://tools.ietf.org/html/draft-davidben-tls-grease-01) 
that explains this behavior.

What jahash.lua does 
--------------

It does 2 things.

1. A *reassembly_handler*  -- parses Client Hello and pulls out the fields required for the ja3 hash.  The chunk of LuaJIT code at the beginning is a neat way to safely parse packets in LUA.   [API Docs](https://www.trisul.org/docs/lua/reassembly.html)

2. A *new counter group* -- meters hashes and uses the new TRISUL EDGE stream graph analytics to add SNI and Flow Based Vertices


Code
----

The  relevant piece of code that removes the GREASE values 

````
      -- kick out GREASE values  from all tables (see RFC) 
      -- since they can appear at random positions (generating a different hash)
      -- we need to remove them completely 
      for _, ja3f_tbl in ipairs( { ja3f.Cipher, ja3f.SSLExtension, ja3f.EllipticCurve} ) do
          for i=#ja3f_tbl,1,-1 do
            if  GREASE_tbl[ja3f_tbl[i]] then table.remove(ja3f_tbl,i);  end
          end
      end

````

