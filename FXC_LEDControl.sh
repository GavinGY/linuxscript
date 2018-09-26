#!/bin/bash

# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*
#  > Author  ： Gavin | Zhang GuiYang
#  > Mail    ： gavin.gy.zhang@gmail.com
#  > Date    ： Sep/17/2018
#  > Company ： Foxconn·CNSBG·CPEGBBD·RD
#  > Funciton:  XB6 LED Control
#  > Version :  v1.0 
#  > HowToUse:  tftp -g -r FXC_LEDControl.sh 10.0.0.10
#               chmod 777 FXC_LEDControl.sh
#               ./FXC_LEDControl.sh B/G/R/Y/W/FRNTOFF/ETHON/ETHOFF/MOCAON/MOCAOFF
# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*


CM_TOP_CTRL_PIN_MUX_CTRL_1=0xd3880104  #FRNT_LED_G/AU43/BNM_GPIO_000 FRNT_LED_B/AT42/BNM_GPIO_003
GPIO_PER_DIR_031_000=0xd3c00500        #FRNT B/G SET"1"=> outut
GPIO_PER_DATA_031_000=0xd3c00528       #FRNT B/G

AON_PIN_CTRK_PIN_MUX_CTRL_0=0xf0410700 #FRNT_LED_W/B3/AON_GPIO_06 FRNT_LED_R/A4/AON_GPIO_07
AON_PIN_CTRK_PIN_MUX_CTRL_1=0xf0410704 #FRNT_LED_Y/B2/AON_GPIO_10 MOCA_LED/C4/AON_GPIO_14
GIO_AON_IODIR_LO=0xf0417008            #FRNT W/R/Y/MOCA_LED 06/07/10/14 SET"0"=> outut
GIO_AON_DATA_LO=0xf0417004             #FRNT W/R/Y/MOCA_LED 06/07/10/14 

SUN_TOP_CTRL_PIN_MUX_CTRL_4=0xf0404110 #GPHY2_LINK_ACT_N/AE1/GPIO_021 GPHY2_LINK1G_N/AG3/GPIO_022 GPHY0_LINK_ACT_N/AF1/GPIO_023 GPHY0_LINK1G_N/AF4/GPIO_024
GPIO_DIR_31_00=0xf040a008       	   #GPHY 1/2/3/4 SET"0"=> outut
GPIO_DATA_31_00=0Xf040a004             #GPHY 1/2/3/4

function LED_Initialize() {
    val=`devmem $CM_TOP_CTRL_PIN_MUX_CTRL_1`   
    val=$(($val & 0xFFFF0FF0))              
    devmem $CM_TOP_CTRL_PIN_MUX_CTRL_1 32 $val 
    val=`devmem $AON_PIN_CTRK_PIN_MUX_CTRL_0`
    val=$(($val & 0x00FFFFFF)) 
    devmem $AON_PIN_CTRK_PIN_MUX_CTRL_0 32 $val
    val=`devmem $AON_PIN_CTRK_PIN_MUX_CTRL_1`
    val=$(($val & 0xF0FFF0FF)) 
    devmem $AON_PIN_CTRK_PIN_MUX_CTRL_1 32 $val
    val=`devmem $SUN_TOP_CTRL_PIN_MUX_CTRL_4`
    val=$(($val & 0x0000FFFF)) 
    devmem $SUN_TOP_CTRL_PIN_MUX_CTRL_4 32 $val

	val=`devmem $GPIO_PER_DIR_031_000`       
	val=$(($val | 0x00000009))          
	devmem $GPIO_PER_DIR_031_000 32 $val 
	val=`devmem $GIO_AON_IODIR_LO`                                                                                                                  
	val=$(($val & 0xFFFFBB3F))   #SET"0"=output 4/8=1011 3/8=1011 2/8=0011               
	devmem $GIO_AON_IODIR_LO 32 $val  
	val=`devmem $GPIO_DIR_31_00`
	val=$(($val & 0xFE1FFFFF))  
	devmem $GPIO_DIR_31_00 32 $val          
}

function LED_Control() {
	status=$1
    if [ $status = 1 ]; then 
		val=`devmem $GPIO_PER_DATA_031_000`
		val=$(($val | 0x00000008))  
		devmem $GPIO_PER_DATA_031_000 32 $val
		echo "Front Panel Blue LED ON."
    elif [ $status = 2 ]; then 
		val=`devmem $GPIO_PER_DATA_031_000`
		val=$(($val | 0x00000001))  
		devmem $GPIO_PER_DATA_031_000 32 $val
		echo "Front Panel Green LED ON."
	elif [ $status = 3 ]; then 
		val=`devmem $GIO_AON_DATA_LO`
		val=$(($val | 0x00000080))  
		devmem $GIO_AON_DATA_LO 32 $val
		echo "Front Panel RED LED ON."
	elif [ $status = 4 ]; then 
		val=`devmem $GIO_AON_DATA_LO`
		val=$(($val | 0x00000400))  
		devmem $GIO_AON_DATA_LO 32 $val
		echo "Front Panel Yellow LED ON."
	elif [ $status = 5 ]; then 
		val=`devmem $GIO_AON_DATA_LO`
		val=$(($val | 0x00000040))  
		devmem $GIO_AON_DATA_LO 32 $val
		echo "Front Panel White LED ON."
    elif [ $status = 6 ]; then 
		val=`devmem $GPIO_PER_DATA_031_000`
		val=$(($val & 0xFFFFFFF6))                               
		devmem $GPIO_PER_DATA_031_000 32 $val
		val=`devmem $GIO_AON_DATA_LO`
		val=$(($val & 0xFFFFFB3F))  
		devmem $GIO_AON_DATA_LO 32 $val
		echo "Front Panel LED OFF ALL."
	elif [ $status = 7 ]; then 
		val=`devmem $GPIO_DATA_31_00`
		val=$(($val | 0x01E00000)) 
		devmem $GPIO_DATA_31_00 32 $val
		echo "Ethernet LED ON."
	elif [ $status = 8 ]; then 
		val=`devmem $GPIO_DATA_31_00`
		val=$(($val & 0xFE1FFFFF))
		devmem $GPIO_DATA_31_00 32 $val
		echo "Ethernet LED OFF."
	elif [ $status = 9 ]; then 
		val=`devmem $GIO_AON_DATA_LO`
		val=$(($val | 0x00004000)) #SET"1" 4/8=0100="4"  
		devmem $GIO_AON_DATA_LO 32 $val
		echo "MOCA LED ON."
	elif [ $status = 10 ]; then 
		val=`devmem $GIO_AON_DATA_LO`
		val=$(($val & 0xFFFFBFFF)) #SET"0" 4/8=1011="B"  
		devmem $GIO_AON_DATA_LO 32 $val
		echo "MOCA LED OFF."
    fi
}

LED_Initialize
if [ $1 = "B" ]; then
	LED_Control 6
    LED_Control 1
elif [ $1 = "G" ]; then 
	LED_Control 6
    LED_Control 2
elif [ $1 = "R" ]; then 
	LED_Control 6
    LED_Control 3
elif [ $1 = "Y" ]; then 
	LED_Control 6
    LED_Control 4
elif [ $1 = "W" ]; then
	LED_Control 6 
    LED_Control 5
elif [ $1 = "FRNTOFF" ]; then 
    LED_Control 6
elif [ $1 = "ETHON" ]; then 
    LED_Control 7
elif [ $1 = "ETHOFF" ]; then 
    LED_Control 8
elif [ $1 = "MOCAON" ]; then 
    LED_Control 9
elif [ $1 = "MOCAOFF" ]; then 
    LED_Control 10
else
    echo "please input B/G/R/Y/W/OFFALL"
fi     
