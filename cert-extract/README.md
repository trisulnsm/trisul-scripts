Print certificate chain 
=======================


Print the SSL certificate chain of all HTTPS connections from a particular host.

Sample run

````
C:\Users\Vivek\Documents\devbo\us\certxtrp>ruby csx.rb demo2.trisul.org 12001 192.168.1.105 https
Enter PEM pass phrase:

Certificate chain for 65.55.184.155 to 192.168.1.105
        www.update.microsoft.com (Microsoft)
          Microsoft Secure Server Authority ()
          Microsoft Secure Server Authority ()
            Microsoft Internet Authority ()
            Microsoft Internet Authority ()
              GTE CyberTrust Global Root (GTE Corporation)

Certificate chain for 65.55.184.27 to 192.168.1.105
        www.update.microsoft.com (Microsoft)
          Microsoft Secure Server Authority ()
          Microsoft Secure Server Authority ()
            Microsoft Internet Authority ()
            Microsoft Internet Authority ()
              GTE CyberTrust Global Root (GTE Corporation)

Certificate chain for 198.232.168.144 to 192.168.1.105
        registration2.services.openoffice.org (Sun Microsystems, Inc)
          Sun Microsystems Inc SSL CA (Sun Microsystems Inc)
          Sun Microsystems Inc SSL CA (Sun Microsystems Inc)
             (VeriSign, Inc.)
             (VeriSign, Inc.)
               (VeriSign, Inc.)

````
