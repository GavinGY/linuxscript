#!/bin/bash

function flash_power_led() {
        status=$1
	
        PINMUX_MASK=0x00000000
		PINMUX_MASK_3=0x0000ffff
		PINMUX_MASK_4=0xff0fffff
		
        CM_TOP_CTRL_PIN_MUX_CTRL_0=0xd3880104
		CM_TOP_CTRL_PIN_MUX_CTRL_3=0xd388010c
		SUN_TOP_CTRL_PIN_MUX_CTRL_4=0xf0404110
		
        GPIO_PER_DIR_031_000=0xd3c00500
		GPIO_DIR_31_00=0xf040a008
		
        GPIO_PER_DATA_031_000=0xd3c00528
		GPIO_DATA_31_00=0Xf040a004

        #read CM_TOP_CTRL_PIN_MUX_CTRL_0
        val=`devmem $CM_TOP_CTRL_PIN_MUX_CTRL_0`
        #and value with PINMUX_MASK to enable bnm_gpio_000 as GPIO
        val=$(($val&$PINMUX_MASK))
        #write CM_TOP_CTRL_PIN_MUX_CTRL_0
        devmem $CM_TOP_CTRL_PIN_MUX_CTRL_0 32 $val
		
		#read CM_TOP_CTRL_PIN_MUX_CTRL_3
        val=`devmem $CM_TOP_CTRL_PIN_MUX_CTRL_3`
        #and value with PINMUX_MASK to enable bnm_gpio_000 as GPIO
        val=$(($val&$PINMUX_MASK_3))
        #write CM_TOP_CTRL_PIN_MUX_CTRL_3
        devmem $CM_TOP_CTRL_PIN_MUX_CTRL_3 32 $val
		
		#SUN_TOP_CTRL_PIN_MUX_CTRL_4
        val=`devmem $SUN_TOP_CTRL_PIN_MUX_CTRL_4`
        #and value with PINMUX_MASK to enable bnm_gpio_000 as GPIO
        val=$(($val&$PINMUX_MASK_4))
        #write SUN_TOP_CTRL_PIN_MUX_CTRL_4
        devmem $SUN_TOP_CTRL_PIN_MUX_CTRL_4 32 $val

        #read GPIO_PER_DIR_031_000
        val=`devmem $GPIO_PER_DIR_031_000`
        #toggle bit 0 to 1 to enable output on bnm_gpio_000
        val=$(($val|0xFFFFFFFF))
        #write GPIO_PER_DIR_031_000
        devmem $GPIO_PER_DIR_031_000 32 $val
		
		#read GPIO_DIR_31_00
        val=`devmem $GPIO_DIR_31_00`
        #toggle bit 0 to 1 to enable output on bnm_gpio_000
        val=$(($val & $PINMUX_MASK_4))
        #write GPIO_PER_DIR_031_000
        devmem $GPIO_DIR_31_00 32 $val

	    if [ $status = 1 ]  
		then #led_on
            wl -i wl0 ledbh 09 0
			wl -i wl1 ledbh 10 0
			devmem 0xf0417004 32 0x000E2040 #WPS
			#devmem 0xf040a004 32 0xC0803000 #MoCA on
			val=`devmem $GPIO_DATA_31_00`
		    val=$(($val | 0x00F00000))
            devmem $GPIO_DATA_31_00 32 $val
			
			val=`devmem $GPIO_PER_DATA_031_000`
		    val=$(($val&0x00000000))
            devmem $GPIO_PER_DATA_031_000 32 $val
			
			echo hello-gavin led on
        else #led_off
            wl -i wl0 ledbh 09 1
			wl -i wl1 ledbh 10 1
			devmem 0xf0417004 32 0x000E2240 #WPS
			#devmem 0xf040a004 32 0xC0003000 #MoCA off
		    val=`devmem $GPIO_DATA_31_00`
		    val=$(($val & 0xFF0FFFFF))
            devmem $GPIO_DATA_31_00 32 $val
			
			val=`devmem $GPIO_PER_DATA_031_000`
		    val=$(($val|0xFFFFFFFF))
            devmem $GPIO_PER_DATA_031_000 32 $val
			
			echo hello-gavin led off
        fi
		
}

sleep 25

if [ $1 = "on" ]; then
   flash_power_led 1
   #echo hello-gavin led on
elif [ $1 = "off" ]; then 
   flash_power_led 0
   #echo hello-gavin led off
else
    echo "please input on off"
fi     


