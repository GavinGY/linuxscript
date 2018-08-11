#!/bin/bash

Detection_ServerName()  
{  
    hostname
}

res=`hostname`      
serverName=$(echo ${res%%/*})  
echo "Server Name is: $serverName"
if [ "$serverName" = "Dream" ]; then 
	echo "Server is: $serverName"
else
	echo "Server is: Other."
fi      

