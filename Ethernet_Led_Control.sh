#!/bin/bash

# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*
#  > Author  ： Gavin | Zhang GuiYang
#  > Mail    ： gavin.gy.zhang@gmail.com
#  > Date    ： 2018.07.28
#  > Company ： Foxconn·CNSBG·CPEGBBD·RD
#  > Funciton:  XB6 Ethernet LED Control
#  > Version :  v1.0 
#  > HowToUse:  cd /tmp
#               tftp -g -r Ethernet_LED_Control.sh 192.168.0.11
#               chmod 775 Ethernet_LED_Control.sh
#               ./Ethernet_LED_Control.sh on/off
# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*

function ethernet_led() {

    # GPHY2_LINK_ACT_N ==> AE1 ==> GPIO_021 ==> SUN_TOP_CTRL_PIN_MUX_CTRL_4 ==> 19:16
    # GPHY2_LINK1G_N   ==> AG3 ==> GPIO_022 ==> SUN_TOP_CTRL_PIN_MUX_CTRL_4 ==> 23:20
    # GPHY0_LINK_ACT_N ==> AF1 ==> GPIO_023 ==> SUN_TOP_CTRL_PIN_MUX_CTRL_4 ==> 27:24
    # GPHY0_LINK1G_N   ==> AF4 ==> GPIO_024 ==> SUN_TOP_CTRL_PIN_MUX_CTRL_4 ==> 31:28
    
    SUN_TOP_CTRL_PIN_MUX_CTRL_4=0xf0404110 #GPHY2_LINK_ACT_N/AE1/GPIO_021 GPHY2_LINK1G_N/AG3/GPIO_022 GPHY0_LINK_ACT_N/AF1/GPIO_023 GPHY0_LINK1G_N/AF4/GPIO_024
    GPIO_DIR_31_00=0xf040a008              #GPHY 1/2/3/4 SET"0"=> outut
    GPIO_DATA_31_00=0Xf040a004             #GPHY 1/2/3/4

    val=`devmem $SUN_TOP_CTRL_PIN_MUX_CTRL_4`
    val=$(($val & 0x0000FFFF)) 
    devmem $SUN_TOP_CTRL_PIN_MUX_CTRL_4 32 $val

    val=`devmem $GPIO_DIR_31_00`
    val=$(($val & 0xFE1FFFFF))  
    devmem $GPIO_DIR_31_00 32 $val  

	status=$1
	
    if [ $status = 1 ]  
    then #led_on
		val=`devmem $GPIO_DATA_31_00`
		val=$(($val | 0x01E00000))  # 1 ==> 27:24 E ==> 23:20 | 31:28 27:24 23:20 19:16 15:12 11:8 7:4 3:0
		devmem $GPIO_DATA_31_00 32 $val
		echo led on
    else #led_off
		val=`devmem $GPIO_DATA_31_00`
		val=$(($val & 0xFE1FFFFF))
		devmem $GPIO_DATA_31_00 32 $val
		echo led off
    fi
}


if [ $1 = "on" ]; then
   ethernet_led 1
elif [ $1 = "off" ]; then 
   ethernet_led 0
else
    echo "please input on or off"
fi     




