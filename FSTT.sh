#!/bin/bash

#By Gavin

Testfile="/tmp/file.ts"
Copyfile="/tmp/file.cp"
LogFile="/usr/local/sbin/FSTT.log"
SystemLog="System >>>:  " 

Headline="
   
   ##########################################################################
   ##########################################################################
   -----            File system read and write test program             -----
   -----                          NandFlash                             -----
   -----                                        FSTT FS-Test-Tools V1.1 -----
   -----    Tools by the Foxconn Cable SoftWare R&D team.    2018/03/21 -----
   ##########################################################################
   ##########################################################################
   
   "

file_make(){  #50MB file size  10min   "10000000"
      #date	  
	  touch $1
	  for((i=1;i<=10000000;i++));
      do 
	     echo "$RANDOM" >> $1
      done  
	  #date
}

Do_md5sum()  
{  
    md5sum $1
}
 
Get_Time()
{
  date
}

while true  #main process
do
   echo "$Headline"
   echo "   ********************* Program initialization starts. *********************"
   echo " "
   echo "   $SystemLog Please sure that the Program is executed in /usr/local/sbin/"
   echo " "
   echo "   $SystemLog Log file save location: $LogFile"
   echo "$Headline" >> $LogFile #Log Save 文件
   echo " "
   
   if [ ! -f "$Testfile" ]; then   #elif [];then	 #file no exit  
      echo "   $SystemLog Creating the test file."
	  echo " " 
	  echo "   $SystemLog About 10 minutes .............."
      file_make $Testfile
	  echo "   $SystemLog File creation complete !! "
   else   #file exit
	  #rm -rf $Testfile
	  #file_make $Testfile
	  echo "   $SystemLog Test file exists !  "
   fi
   
   echo " "   
   res=`Do_md5sum $Testfile`     #echo  $?  #返回命令执行结果          #echo "res: "${res} #返回命令返回值     
   Standard_check_value=$(echo ${res%%/*})  #对返回的字符串做分割“/” 并且传递给变量
   echo "   $SystemLog Standard check value - "$Standard_check_value
   echo " "
   echo "   ********************** Program initialization end. ***********************"
   echo " "
    
   while true  
   do
       cp $Testfile $Copyfile
       echo "$SystemLog copy file ok!"
       #echo "$RANDOM" >> $Copyfile
	   
       res2=`Do_md5sum $Copyfile`
	   Wait_check_value=$(echo ${res2%%/*}) 
	   echo "$SystemLog Wait check value - "$Wait_check_value
	   
	   res3=`Get_Time`
	   Current_time=$(echo ${res3}) 
	   
	   if [ "$Standard_check_value" = "$Wait_check_value" ]; then   #$Standard_check_value -eq $Wait_check_value #判断整数
		   echo "$SystemLog check ok!"
		   #echo "$SystemLog $Current_time     check ok" >> $LogFile #Log Save 文件
	   else
		   echo "$SystemLog check failed!"
		   echo "$SystemLog $Current_time     check failed!" >> $LogFile #Log Save 文件
	   fi
	   
	   rm -rf $Copyfile
	   echo "$SystemLog delete file ok!"
	   
	   echo " "
	   echo "-------------------------------------------------------------------"
	   echo " "
	   
	   sleep 10
	   
   done

   #break   #break 1
  
done

   #echo "$1"
   #date
   #sleep 1
   #usleep 300
   
   #进度条功能
   # b=''
   # for ((i=0;$i<=100;i+=2))
   # do
		# printf "progress:[%-50s]%d%%\r" $b $i
		# usleep 100000
		# b=#$b
   # done
   # echo
   #改进后的进度条
   # c=2
   # b=''
	# printf "progress:[%-49s]%d%%\r" $b $c
	# a=$[$a+1]
	# if [ $a -gt 199999 ]; then
		# a=0
		# b=#$b
		# c=$[$c+2]		
	# fi

      
   # for((i=1;i<=10;i++));
   # do 
      #cp ./file.test /tmp/file$i.test 
	  
	  # echo "OK"
	  # echo $i
   # done
   