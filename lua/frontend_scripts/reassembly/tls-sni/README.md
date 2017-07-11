Server Name Indication based metrics
====================================

1. A new counter group called "SNI" 
    1. meter 0 : bandwidth  per hostname
	2. meter 1 : flows/hits per hostname

2. A new resource group called "SNI" contains IP->SNI hostname mapping 


** Requires the BitMaul library ** 
