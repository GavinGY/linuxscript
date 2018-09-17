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

    # GPHY2_LINK_ACT_N ==> AE1 ==> GPIO_021 ==> CM_TOP_CTRL_PIN_MUX_CTRL_3 ==> 23:20
    # GPHY2_LINK1G_N   ==> AG3 ==> GPIO_022 ==> CM_TOP_CTRL_PIN_MUX_CTRL_3 ==> 27:24
    # GPHY0_LINK_ACT_N ==> AF1 ==> GPIO_023 ==> CM_TOP_CTRL_PIN_MUX_CTRL_3 ==> 31:28
    # GPHY0_LINK1G_N   ==> AF4 ==> GPIO_024 ==> CM_TOP_CTRL_PIN_MUX_CTRL_4 ==> 03:00
    
	PINMUX_MASK_3=0x000FFFFF
	PINMUX_MASK_4=0xFFFFFFF0

    CM_TOP_CTRL_PIN_MUX_CTRL_3=0xd388010c  # PIN_MUX Physical Address
    CM_TOP_CTRL_PIN_MUX_CTRL_4=0xd3880110  # PIN_MUX Physical Address

    GPIO_DIR_31_00=0xf040a008       # PIN_DIR Physical Address

    GPIO_DATA_31_00=0Xf040a004       # PIN_DATA Physical Address

    
    #read CM_TOP_CTRL_PIN_MUX_CTRL_3
    val=`devmem $CM_TOP_CTRL_PIN_MUX_CTRL_3`
    #and value with PINMUX_MASK to enable bnm_gpio_021/022/023 as GPIO
    val=$(($val&$PINMUX_MASK_3))
    #write CM_TOP_CTRL_PIN_MUX_CTRL_3
    devmem $CM_TOP_CTRL_PIN_MUX_CTRL_3 32 $val

    #read CM_TOP_CTRL_PIN_MUX_CTRL_4
    val=`devmem $CM_TOP_CTRL_PIN_MUX_CTRL_4`
    #and value with PINMUX_MASK to enable bnm_gpio_024 as GPIO
    val=$(($val&$PINMUX_MASK_4))
    #write CM_TOP_CTRL_PIN_MUX_CTRL_4
    devmem $CM_TOP_CTRL_PIN_MUX_CTRL_4 32 $val

	#read GPIO_DIR_31_00
	val=`devmem $GPIO_DIR_31_00`
	#toggle bit 0 to 1 to enable output on bnm_gpio_000
	val=$(($val & $PINMUX_MASK_3))
	#write GPIO_PER_DIR_31_00
	devmem $GPIO_DIR_31_00 32 $val
	
	#read GPIO_DIR_31_00
	val=`devmem $GPIO_DIR_31_00`
	#toggle bit 0 to 1 to enable output on bnm_gpio_000
	val=$(($val & $PINMUX_MASK_4))
	#write GPIO_PER_DIR_31_00
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




