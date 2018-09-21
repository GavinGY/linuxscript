#!/bin/bash

# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*
#  > Author  ： Gavin | Zhang GuiYang
#  > Mail    ： gavin.gy.zhang@gmail.com
#  > Date    ： Sep/17/2018
#  > Company ： Foxconn·CNSBG·CPEGBBD·RD
#  > Funciton:  XB6 Front LED Control
#  > Version :  v1.0 
#  > HowToUse:  tftp -g -r Front_LED_Control.sh 10.0.0.10
#               chmod 777 Front_LED_Control.sh
#               ./Front_LED_Control.sh B/G/R/Y/W/OFFALL
# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*

CM_TOP_CTRL_PIN_MUX_CTRL_1=0xd3880104     
GPIO_PER_DIR_031_000=0xd3c00500         
GPIO_PER_DATA_031_000=0xd3c00528          
GIO_AON_IODIR_LO=0xf0417008               
GIO_AON_DATA_LO=0xf0417004  

function Front_LED_Initialize() {
    val=`devmem $CM_TOP_CTRL_PIN_MUX_CTRL_1`   
    val=$(($val & 0xFFFF0FF0))              
    devmem $CM_TOP_CTRL_PIN_MUX_CTRL_1 32 $val 
	val=`devmem $GPIO_PER_DIR_031_000`       
	val=$(($val | 0x00000009))          
	devmem $GPIO_PER_DIR_031_000 32 $val       
	val=`devmem $GIO_AON_IODIR_LO`                                                                                                                  
	val=$(($val & 0xFFFFFB3F))                
	devmem $GIO_AON_IODIR_LO 32 $val          
}

function Front_LED_Control() {
	status=$1
    if [ $status = 1 ]; then 
		val=`devmem $GPIO_PER_DATA_031_000`
		val=$(($val | 0x00000008))  
		devmem $GPIO_PER_DATA_031_000 32 $val
		echo Blue LED ON
    elif [ $status = 2 ]; then 
		val=`devmem $GPIO_PER_DATA_031_000`
		val=$(($val | 0x00000001))  
		devmem $GPIO_PER_DATA_031_000 32 $val
		echo Green LED ON
	elif [ $status = 3 ]; then 
		val=`devmem $GIO_AON_DATA_LO`
		val=$(($val | 0x00000080))  
		devmem $GIO_AON_DATA_LO 32 $val
		echo RED LED ON
	elif [ $status = 4 ]; then 
		val=`devmem $GIO_AON_DATA_LO`
		val=$(($val | 0x00000400))  
		devmem $GIO_AON_DATA_LO 32 $val
		echo Yellow LED ON
	elif [ $status = 5 ]; then 
		val=`devmem $GIO_AON_DATA_LO`
		val=$(($val | 0x00000040))  
		devmem $GIO_AON_DATA_LO 32 $val
		echo White LED ON
    elif [ $status = 0 ]; then 
		val=`devmem $GPIO_PER_DATA_031_000`
		val=$(($val & 0xFFFFFFF6))                               
		devmem $GPIO_PER_DATA_031_000 32 $val
		val=`devmem $GIO_AON_DATA_LO`
		val=$(($val & 0xFFFFFB3F))  
		devmem $GIO_AON_DATA_LO 32 $val
		echo LED OFF ALL
    fi
}

Front_LED_Initialize
Front_LED_Control 0
if [ $1 = "B" ]; then
    Front_LED_Control 1
elif [ $1 = "G" ]; then 
    Front_LED_Control 2
elif [ $1 = "R" ]; then 
    Front_LED_Control 3
elif [ $1 = "Y" ]; then 
    Front_LED_Control 4
elif [ $1 = "W" ]; then 
    Front_LED_Control 5
elif [ $1 = "OFFALL" ]; then 
    Front_LED_Control 0
else
    echo "please input B/G/R/Y/W/OFFALL"
fi     
