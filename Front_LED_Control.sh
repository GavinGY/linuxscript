#!/bin/bash

# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*
#  > Author  ： Gavin | Zhang GuiYang
#  > Mail    ： gavin.gy.zhang@gmail.com
#  > Date    ： Sep/17/2018
#  > Company ： Foxconn·CNSBG·CPEGBBD·RD
#  > Funciton:  XB6 Front LED Control
#  > Version :  v1.0 
#  > HowToUse:  tftp -g -r Front_LED_Control.sh 10.0.0.10
#               chmod 775 Front_LED_Control.sh
#               ./Front_LED_Control.sh B/G/R/Y/W/OFFALL
# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*
#                                              PIN_MUX Register         PIN_DIR Register     PIN_DATA Register
#                                             value "0000" ==> GPIO   BNM_GPIO "1"==>Output   hight==>1 low==>0
#                                                                             "0"==>Input
#                                                                   CM_TOP_CTRL = GPIO_PER_DIR
#
#                                                                   SUN_TOP_CTRL "0"=O "1"=I
#                                                                   SUN_TOP_CTRL = GPIO_DIR        
# BNM_GPIO_xxx ==> MIPS GPIO ("BNM") ==> CM_TOP_CTRL_PIN_MUX_CTRL_xx/GPIO_PER_DIR_xxa_xxb/GPIO_PER_DATA_xxa_xxb
# FRNT_LED_B	AT42	BNM_GPIO_003	  
# FRNT_LED_G	AU43	BNM_GPIO_000
#                       GIO_AON   BCM3390 B0 Programmer's Register Reference Guide (Part C) ==> P1153
# FRNT_LED_R	A4 		AON_GPIO_07
# FRNT_LED_Y	B2		AON_GPIO_10
# FRNT_LED_W	B3		AON_GPIO_06

# definition register
    CM_TOP_CTRL_PIN_MUX_CTRL_1=0xd3880104      # PIN_MUX Physical Address
    GPIO_PER_DIR_031_000=0xd3c00500            # PIN_DIR Physical Address   MIPS GPIO ("BNM")
    GPIO_PER_DATA_031_000=0xd3c00528           # PIN_DATA Physical Address  MIPS GPIO ("BNM")

    GIO_AON_IODIR_LO=0xf0417008                # PIN_DIR Physical Address FOR AON_GPIO[19:0]  "0"==>output "1"==>input
    GIO_AON_DATA_LO=0xf0417004                 # PIN_DATA Physical Address FOR AON_GPIO[19:0]
function Front_LED_Initialize() {

# Enable BNM GPIO Function
    val=`devmem $CM_TOP_CTRL_PIN_MUX_CTRL_1`   # read CM_TOP_CTRL_PIN_MUX_CTRL_1
    # Set 4/8 1/8 value "0000" | BNM_GPIO_000 ==> 03:00 | BNM_GPIO_003 ==> 15:12 ==> GPIO function
    val=$(($val & 0xFFFF0FF0))                 # 0x00000000 
    devmem $CM_TOP_CTRL_PIN_MUX_CTRL_1 32 $val # Write setting Value

# Setting BNM GPIO Direction
	val=`devmem $GPIO_PER_DIR_031_000`         # read GPIO_PER_DIR_031_000 Value
	# Set value "1" ==> output [BNM_GPIO "1"==>Output "0"==>Input] BNM_GPIO_003/BNM_GPIO_000 ==> 4/32 & 1/32 = 1/8 >"1001"/"9"
	val=$(($val | 0x00000009))                 # 0xFFFFFFFF  
	devmem $GPIO_PER_DIR_031_000 32 $val       # write GPIO_PER_DIR_031_000

# Setting AON GPIO Direction    
	val=`devmem $GIO_AON_IODIR_LO`             # read GIO_AON_IODIR_LO Value
	# Set value "0" ==> output [AON_GPIO "0"==>output "1"==>input] AON_GPIO_06/AON_GPIO_07/AON_GPIO_10 ==> 7/32 & 6/32 = 2/8 >"0011"/"3"
	#                                                                                                            10/32 = 3/8 >"1011"/"B"       
	val=$(($val & 0xFFFFFB3F))                 # 0x00000000  
	devmem $GIO_AON_IODIR_LO 32 $val           # write GIO_AON_IODIR_LO

}

function Front_LED_Control() {

	status=$1
    if [ $status = 1 ]; then 
		val=`devmem $GPIO_PER_DATA_031_000`
		val=$(($val | 0x00000008))  # 0xFFFFFFFF  # FRNT_LED_B/AT42/BNM_GPIO_003 ==>set "1" ==> 1/8>"1000"/"8"
		devmem $GPIO_PER_DATA_031_000 32 $val
		echo Blue LED ON
    elif [ $status = 2 ]; then 
		val=`devmem $GPIO_PER_DATA_031_000`
		val=$(($val | 0x00000001))  # 0xFFFFFFFF  # FRNT_LED_G/AU43/BNM_GPIO_000 ==>set "1" ==> 1/8>"0001"/"1"
		devmem $GPIO_PER_DATA_031_000 32 $val
		echo Green LED ON
	elif [ $status = 3 ]; then 
		val=`devmem $GIO_AON_DATA_LO`
		val=$(($val | 0x00000080))  # 0xFFFFFFFF  # FRNT_LED_R/A4/AON_GPIO_07 ==>set "1" ==> 2/8>"1000"/"8"
		devmem $GIO_AON_DATA_LO 32 $val
		echo RED LED ON
	elif [ $status = 4 ]; then 
		val=`devmem $GIO_AON_DATA_LO`
		val=$(($val | 0x00000400))  # 0xFFFFFFFF  # FRNT_LED_Y/B2/AON_GPIO_10 ==>set "1" ==> 3/8>"0100"/"4"
		devmem $GIO_AON_DATA_LO 32 $val
		echo Yellow LED ON
	elif [ $status = 5 ]; then 
		val=`devmem $GIO_AON_DATA_LO`
		val=$(($val | 0x00000040))  # 0xFFFFFFFF  # FRNT_LED_W/B3/AON_GPIO_06 ==>set "1" ==> 2/8>"0100"/"4"
		devmem $GIO_AON_DATA_LO 32 $val
		echo White LED ON
    elif [ $status = 0 ]; then 
		val=`devmem $GPIO_PER_DATA_031_000`
		                                          # FRNT_LED_B/AT42/BNM_GPIO_003 ==>set "0" ==> 1/8>"0110"
		                                          # FRNT_LED_G/AU43/BNM_GPIO_000 ==>set "0" ==> 1/8>"1110"
		val=$(($val & 0xFFFFFFF6))  # 0x00000000  #                                         ==> 1/8>"0110"/"6"
		devmem $GPIO_PER_DATA_031_000 32 $val

		val=`devmem $GIO_AON_DATA_LO`
		                                          # FRNT_LED_R/A4/AON_GPIO_07 ==>set "0" ==> 2/8>"0111"
		                                          # FRNT_LED_Y/B2/AON_GPIO_10 ==>set "0" ==> 3/8>"1011"
		                                          # FRNT_LED_W/B3/AON_GPIO_06 ==>set "0" ==> 2/8>"1011"
		val=$(($val & 0xFFFFFB3F))  # 0x00000000  #                                      ==> 3/8 >"1011"/"B" 2/8 >"0011"/"3"  
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
