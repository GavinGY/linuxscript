#!/bin/bash
#!/usr/bin/expect 

# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*
#  > Author  ： Gavin | Zhang GuiYang
#  > Mail    ： gavin.gy.zhang@gmail.com
#  > Date    ： May/13/2018
#  > Company ： Foxconn·CNSBG·CPEGBBD·RD
#  > Funciton:  
#  > Version :  v1.0 
#  > HowToUse:  sudo vi /etc/profile
#               export PATH=/home/gavin/project/linuxscript:$PATH
#               source /etc/profile
# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*

LH_Server=10.141.198.146
gavin_password=123456

echo "I'am a Command Line Interface IDE."


case $1 in
	eCos)
		echo "eCos = OpenBFC_bfc(docsis) + OpenBFC_cxc(emta)"  
        case $2 in
        	build)
		 		./build_package.sh cm CmBldr cleanall B0
		    	./build_package.sh cm CmBldr B0
		    	;;
		esac
    	;;
	RDK)
        echo "RDK = OpenBFC RDK-M" 
        case $2 in
        	build)
		        rm -rf build-brcm93390
				echo -e "1\n" | source meta-rdk-broadcom-generic-rdk/setup-environment-broadcom-generic-rdkb
   				#yes 1 | head -1
   				res=`pwd`
			 	echo $res
   				cd $res/build-brcm93390/
   				res=`pwd`
			 	echo $res
    			bitbake rdk-generic-broadband-image
		    	;;
		esac
    	;;
	PCI)
    	echo "Create PCI image or downloand iamge."  
        case $2 in
        	build)
				echo -e "$gavin_password\n" | scp tmp/deploy/images/brcm93390/zImage gavin@$LH_Server:/opt/tools_xb6/PCITool/img-components/
				echo -e "$gavin_password\n" | scp tmp/deploy/images/brcm93390/rdk-generic-broadband-image-brcm93390.tar.gz gavin@10.141.198.146:/opt/tools_xb6/PCITool/img-components/
				
				cd /opt/tools_xb6/PCITool/img-components/rootfs/
				rm -rf ./*
			    ls -l
			    tar zxvf ../rdk-generic-broadband-image-brcm93390.tar.gz
			    cd ../../
			    res=`date +%Y%m%d%H%M`
			    ./pci2.sh PCI0_Prod_17.1.3_P_$res 1 zImage
			    ls -l workdir/
		    	;;
		    DN)

				;;
		esac
    	;;
esac