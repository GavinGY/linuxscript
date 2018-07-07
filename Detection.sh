#!/bin/bash

#********************************** About ***********************************
# Funtion : After WIFI startup, execute some commands automatically.
# Author  : Gavin | Zhang Guiyang 
# Company : Foxconn-CNSBG-SZLH-CPEBBD-SW-R&D
# Date    : 2018 Year March 27
#****************************************************************************

#******************************** Comments **********************************
# Comments:
#     |----- Location:
#     |           |---- cd /etc/init.d/
#     |           |---- tftp -g -r Detection.sh 10.0.0.219
#     |           |---- chmod 777 ./Detection.sh
#     |----- Execution:
#                 |---- chmod 777 /etc/utopia/utopia_init.sh
#                 |---- vi /etc/utopia/utopia_init.sh
#                 |---- add to line 59: /etc/init.d/Detection.sh
#
#****************************************************************************

SystemLog="Tool Log >>>:  " 
Headline="
   
   ###############################################################
   ***************************************************************
   -----         Detection wifi is up for OpenBFC            -----
   -----  Tools by the Foxconn Cable SW R&D team. 2018/03/27 -----
   ***************************************************************
   ###############################################################
   
   "
Endline="
   
   ###############################################################
   ***************************************************************
   -----         WiFi Command Execution OK !!!!!!            -----
   ***************************************************************
   ###############################################################
   
   "
Detection()  
{  
    wl -i  wl1 isup
}
 
while true  #main process
do
   echo "$Headline"
   echo "   $SystemLog Wifi startup is being detected."
   sleep 40
   echo " "
   
   while true  
   do
	   res=`Detection`      
	   wl1_status=$(echo ${res%%/*})  
       if [ "$wl1_status" = "1" ]; then   
		   echo "$SystemLog Wifi Status OK !!! "
           break
	   fi      
   done
   
   echo "$SystemLog Doing something..."
   sleep 5
   wl -i wl1 down 
   wl -i wl1 bw_cap 5g 0xf
   wl -i wl1 chanspec 36/160 
   wl -i wl1 up 
   sleep 5
   echo "$Endline"

   break 
  
done

