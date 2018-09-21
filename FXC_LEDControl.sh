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
#               ./FXC_LEDControl.sh B/G/R/Y/W/FRNTOFF/ETHON/ETHOFF
# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*

CM_TOP_CTRL_PIN_MUX_CTRL_1=0xd3880104   
CM_TOP_CTRL_PIN_MUX_CTRL_3=0xd388010c  # PIN_MUX Physical Address
CM_TOP_CTRL_PIN_MUX_CTRL_4=0xd3880110  # PIN_MUX Physical Address
GPIO_PER_DIR_031_000=0xd3c00500         
GPIO_PER_DATA_031_000=0xd3c00528
GPIO_DIR_31_00=0xf040a008       # PIN_DIR Physical Address
GPIO_DATA_31_00=0Xf040a004       # PIN_DATA Physical Address           
GIO_AON_IODIR_LO=0xf0417008               
GIO_AON_DATA_LO=0xf0417004  

function LED_Initialize() {
    val=`devmem $CM_TOP_CTRL_PIN_MUX_CTRL_1`   
    val=$(($val & 0xFFFF0FF0))              
    devmem $CM_TOP_CTRL_PIN_MUX_CTRL_1 32 $val 
    val=`devmem $CM_TOP_CTRL_PIN_MUX_CTRL_3`
    val=$(($val & 0x000FFFFF))
    devmem $CM_TOP_CTRL_PIN_MUX_CTRL_3 32 $val
    val=`devmem $CM_TOP_CTRL_PIN_MUX_CTRL_4`
    val=$(($val & 0xFFFFFFF0))
    devmem $CM_TOP_CTRL_PIN_MUX_CTRL_4 32 $val

	val=`devmem $GPIO_PER_DIR_031_000`       
	val=$(($val | 0x00000009))          
	devmem $GPIO_PER_DIR_031_000 32 $val 
	val=`devmem $GPIO_DIR_31_00`
	val=$(($val & 0x000FFFF0))
	devmem $GPIO_DIR_31_00 32 $val      
	val=`devmem $GIO_AON_IODIR_LO`                                                                                                                  
	val=$(($val & 0xFFFFFB3F))                
	devmem $GIO_AON_IODIR_LO 32 $val          
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
else
    echo "please input B/G/R/Y/W/OFFALL"
fi     
