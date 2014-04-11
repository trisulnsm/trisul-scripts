Simplest script - hello world 
=============================

Creates a skeleton directory with key and cert required to connect to trisul

Simple script  to a Trisul sensor and print its identifying information. 

Demostrates framework, gems, and certificate structure required to make
TRP scripts work. 

Copy the helloworld directory to start writing  your own scripts 

How to run
----------

````
git clone https://github.com/vivekrajan/trisul-scripts.git

cd trisul-scripts/helloworld

ruby hello.rb 192.168.1.222

[btwin@localhost trp]$ ruby hello.rb 192.168.1.222
Enter PEM pass phrase: <<password is client>>
"Connection success"
"SE-LINK"
"Conn-X"
"3.6.1615"



````


