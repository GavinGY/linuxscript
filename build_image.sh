#!/bin/bash
#!/usr/bin/expect 


# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*
#  > Author  ： Gavin | Zhang GuiYang
#  > Mail    ： gavin.gy.zhang@gmail.com
#  > Date    ： May/13/2018
#  > Company ： Foxconn·CNSBG·CPEGBBD·RD
#  > Funciton:  
#  > Version :  v1.0 
#  > HowToUse:  sudo apt-get install tcl
#               apt-get install expect
#               chmod a+x  script.sh 或chmod 755 script.sh   
#               See more info in README.md
# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*

openbfc_folder=openbfc_17.1.3
rdk_folder=rdkm_17.1.3
Product=xb6cox
factorytools_location=/mnt/tftpShareSpace/CCFile_Output
pci_name=Target_pci_name

Key1="toolchain_cm="
Str1="toolchain_cm=\/opt\/toolchains\/eCos-gun\/3.2.1\/zOEMtools_eCos\/eCos20\/gnutools\/mipsisa32-elf-i386-linux\/bin"
Path1=tools/buildConfigB0.cfg

version=P007COX
Key2="#define FOXCONN_SOFTWARE_VERSION"
Str2="#define FOXCONN_SOFTWARE_VERSION \"Prod_17.1.3_${version}\""
Path2=cm/rbb_cm/rbb_cm_src/Bfc/Custom/BfcNonVolDefaults.h

git_password=123456
rdk_factorytools_location=meta-rdk-broadcom-generic-rdk/meta-brcm93390/recipes-foxconn/factorytools/factorytools/
pci_tool_location=/opt/tools_xb6/PCITool/img-components/
while true  #main process
do
    res=`hostname`
	serverName=$(echo ${res%%/*})  
	if [ "$serverName" = "Dream" ]; then 
		echo "Server is: Dream"
	elif [ "$serverName" = "Vison" ]; then 
		echo "Server is: Vison"
	else
		echo "Other Server, hostname is: $serverName"
	fi  

    cd $openbfc_folder/
    res=`git status`
	if [[ $res == *modified* ]]
	then
	  echo "YOU HAVE MODIFIDED FILE IN GIT !!!"
	  #break
	  git reset --hard
	else
	  echo "nothing to commit, working tree clean"
	fi
    git checkout $Product  
expect <<HERE
	spawn git pull
	expect "*password*"
	send "$git_password\r"
	expect "*$"
HERE
    sed -i "s/toolchain_cm=.*/$Str1/g" $Path1
	sed -i "s/#define FOXCONN_SOFTWARE_VERSION.*/$Str2/g" $Path2
    ./build_package.sh cm CmBldr cleanall B0
    ./build_package.sh cm CmBldr B0
    cp -f images/3390/B0/bcm93390smwvg/rg_cm_pc20_components_prod/bcm93390smwvg_pc20/* ../rdkm_17.1.3/meta-rdk-broadcom-generic-rdk/meta-brcm93390/recipes-foxconn/factorytools/factorytools/

    #cd ../$rdk_folder/
    #git status
    #git reset --hard
    #git checkout $Product
    #git pull
    #cp -f ../$openbfc_folder/images/3390/B0/bcm93390smwvg/rg_cm_pc20_components_prod/bcm93390smwvg_pc20/* $rdk_factorytools_location
    #cp -f $factorytools_location/* $rdk_factorytools_location
    p006 
    p006_v2 add brcm.util 				failed
    p006_v3 back to p005   				OK
    p006_v4 p005+cmpart    				OK
    p006_v5 p005+cmpart+qtn             OK
    p006_v6 p005+cmpart+qtn+nvram_mount 

    rm -rf build-brcm93390
    rm -rf sstate-cache/
    source meta-rdk-broadcom-generic-rdk/setup-environment-broadcom-generic-rdkb
    1
    bitbake rdk-generic-broadband-image


# xb6.5
scp tmp/deploy/images/brcm93390smwvg/rdk-generic-broadband-image-brcm93390smwvg.tar.gz gavin@10.141.198.146:/opt/tools_xb6.5/PCITool/img-components/
./pci2.sh Prod_18.2ER2_lab2a_20180912 3 zImage-18.2ER2_FXC.bin

# xb6
scp tmp/deploy/images/brcm93390/rdk-generic-broadband-image-brcm93390.tar.gz gavin@10.141.198.146:/opt/tools_xb6/PCITool/img-components/
cd /opt/tools_xb6/PCITool/img-components/rootfs/
rm -rf ./*
tar zxvf ../rdk-generic-broadband-image-brcm93390.tar.gz
cd ../../
./pci2.sh PCI0_Prod_17.1.3_VDT_P01 1 zImage
ll workdir/

    #cp -f tmp/deploy/images/brcm93390/rdk-generic-broadband-image-brcm93390.tar.gz $pci_tool_location
	#cp -f tmp/deploy/images/brcm93390/zImage $pci_tool_location
	cd /opt/tools_xb6/PCITool/img-components/rootfs/
	rm -rf ./*
    ll
    tar zxvf ../rdk-generic-broadband-image-brcm93390.tar.gz
    cd ../../
    ./pci2.sh PCI0_Prod_17.1.3_P019 1 zImage
    ll workdir/

    cp -r workdir/$pci_name /mnt/tftpShareSpace/

 
    echo "Build OK!"
	break
done

echo "Perform the end!"


 #    line=`sed -n '/'"$KEY"'/=' $FullPath`
	# if [ "$line" == "" ]; then
	# 	echo "is Null"
	# return;
	# else
	# 	echo $line
	# 	sed -i "" "${line}s#.*#"$str"#" $FullPath
	# 	sed -i "" "${line}s/.*/ &/" $FullPath
	# fi

	