# packet reassembly 

(Frontend packet pipeline Trisul script) 

These scripts demonstrate how you can plug your LUA scripts into the TCP packet reassembly framework.


## Index of scripts 


Filename             |                    What it does                  | Demonstrates 
---------------------|--------------------------------------------------|----------------------------
reass1.lua   | prints reassembly call messages | Minimal script demonstrates hooks into reassembly 
reass_filter.lua  | selectively request reassembly support | use of the filter method, accessing IP, Ports from flow object 
savetcp.lua  | save fully reassembled TCP payloads into separate files | saving reassmbled buffers, use lookup tables 
ftp.lua | FTP file extraction with filenames | State management, onmessage(..), selective reassembly, techniques | 



