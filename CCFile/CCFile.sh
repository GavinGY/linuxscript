#!/bin/bash

# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*
#  > Author  ： Gavin | Zhang GuiYang
#  > Mail    ： gavin.gy.zhang@gmail.com
#  > Date    ： August/10/2018
#  > Company ： Foxconn·CNSBG·CPEGBBD·RD
#  > Funciton:  CCFile ==> Check and Copy file from embedded Linux System.
#  > Version :  v1.0 
#  > HowToUse:  See README.md
# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*


# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*
#------------------------         CFG  AREA        --------------------------#
#------------------     you can add new cfg in here     ---------------------#
# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*

Sample_cfg=(
F---folder1   # CCFile Output file save folder location
	fileA
	fileB
	fileC
	fileD
	...
F---folder2   # CCFile Output file save folder location
	fileA
	fileB
	fileC
	...
F---....      # CCFile Output file save folder location
	...
	...
F---folderN
 	fileA
	fileB
	...
)

XB6_NOR_Unit_factory_tools_cfg=(
F---factory_nvram_toos   # CCFile Output file save folder location
	factory_info_test
	factory_nvram
	libfactory_info.so.0.0.0
F---nvram_mount          # CCFile Output file save folder location
	brcm.util
	tch_nvram.sh
F---qtn_wifi             # CCFile Output file save folder location
	libqcsapi_client.so
	libqcsapi_client.so.1
	libqcsapi_client.so.1.0.1
	libql2t.so
	libqwcfg.so
	libqwcfg.so.2.0.0
	qcsapi_pcie
	qcsapi_sockraw
	qcsapi_sockrpc
	qevt_client
	qtn_platform_utils.sh
	qtn_shell_logging_utils.sh
	qtn-core_trace.sh
	qwcfg_test
)

# Please register target cfg into following.
# target_cfg=(${Sample_cfg[@]}) 
target_cfg=(${XB6_NOR_Unit_factory_tools_cfg[@]}) 


# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*
#------------------------         CODE AREA        --------------------------#
#------------------      you can don't have to care     ---------------------#
# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*

tftp_server=$1
checksum=check.sum
CCFile_Output_dir=CCFile_Output

Find_file()
{
	find / -name "$1"
}

Do_md5sum()  
{  
    md5sum $1
}
 
TFTP_push()
{
  tftp -p -l $1 $tftp_server
}

Make_dir()
{
	mkdir $1
	for((i=0;i<$num;i++));  
	do
		mkdir $1/${folder_name[$i]}
	done
}


while true  #main process
do
	num=0
	for((i=0;i<${#target_cfg[@]};i++));  
	do
		export tmp_name="${target_cfg[$i]}"
		if [ "${tmp_name:0:4}" == "F---" ]; then
			#echo ${tmp_name:0:4}
			folder_tag[$i]="folder"${tmp_name#*F---}
			folder_name[$num]=${tmp_name#*F---}
			echo $num $i ${folder_tag[$i]} ${folder_name[$num]}
			num=$[$num+1]
		fi
	done

	if [ ! -d "$CCFile_Output_dir" ];then
        Make_dir $CCFile_Output_dir
	else
		rm -rf $CCFile_Output_dir
		Make_dir $CCFile_Output_dir
	fi

    num=0
	for((i=0;i<${#target_cfg[@]};i++));  
	do
		tmp_name="${folder_tag[$i]}"
		target_file_name=${target_cfg[$i]}

		if [ "${tmp_name:0:6}" != "folder" ]; then
			num=$[$num+1]
            res="s"$num
            echo $res $target_file_name
			echo $res $target_file_name >> $CCFile_Output_dir/$checksum
			res=`Find_file $target_file_name`
		    echo "$res "
		    if [ "$res" != "" ]; then
                cp -f $res $CCFile_Output_dir/$save_file_location/
			 	res=`Do_md5sum $res`
			 	res=$(echo ${res%%/*})
			 	echo "$res "
			 	echo $res >> $CCFile_Output_dir/$checksum
		    else
		    	echo "WARNING : CAN NOT FIND TARGET FILE !!!!!!"
		    	echo "WARNING : CAN NOT FIND TARGET FILE !!!!!!" >> $CCFile_Output_dir/$checksum
		    fi
        else
        	save_file_location=${tmp_name#*folder}
        	echo "folder!!!"
		fi
	done  
	tar zcvf $CCFile_Output_dir.tar.gz $CCFile_Output_dir
    TFTP_push $CCFile_Output_dir.tar.gz
	break
done



# version  0.6  main code

# while true  #main process
# do
# 	if [ ! -f "$checksum" ]; then
# 		echo " " 
# 	else
# 	    rm -rf $checksum
#     fi

# 	for((i=0;i<${#NOR_Unity_factory_tools[@]};i++));  
# 	do
# 		res="s"$i
# 		tools_name=${NOR_Unity_factory_tools[$i]}
# 		echo $res $tools_name
# 		echo $res $tools_name >> $checksum
           
# 		res=`Find_file $tools_name`
# 		res_dir=$(echo ${res%%$tools_name*})
# 	 	echo "$res "
# 	 	echo "$res_dir"
# 	 	cd $res_dir
# 	 	TFTP_push $tools_name
# 	 	cd /tmp
# 	 	res=`Do_md5sum $res`
# 	 	res=$(echo ${res%%/*})
# 	 	echo "$res "
# 	 	echo $res >> $checksum
# 	done  
#     TFTP_push $checksum
# 	break

# done