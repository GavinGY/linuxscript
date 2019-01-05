#!/bin/bash

# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*
#  > Author  ： Gavin | Zhang GuiYang
#  > Mail    ： gavin.gy.zhang@gmail.com
#  > Date    ： Sep/17/2018
#  > Company ： Foxconn·CNSBG·CPEGBBD·RD
#  > Funciton:  CVA4002 LED Control
#  > Version :  v1.0 
#  > HowToUse:  tftp -g -r FXC_LEDControl.sh 10.0.0.10
#               chmod 777 FXC_LEDControl.sh
#               ./FXC_LEDControl.sh ALLON/ALLOFF
# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*

#                                      96
# 95                                   64
# 63                                   32                            
# 31                                   00
# 0000 0000 0000 0000 0000 0000 0000 0000
# 偏移 = （Target_pin_number - 96/64/32/00）+1          

# READ      D1117/D1118  GPIO_045       PIN_MUX_7_19:16      45-32=13+1=14    0xFFFF(1101/D)FFF
# BLUE      D1122        GPIO_081       PIN_MUX_12_03:00     81-64=17+1=18    0xFFF(1101/D)FFFF
# WHITE     D1119        GPIO_099       PIN_MUX_14_11:08                      0xFFFFFFF(0111/7)
# BLUE      D1114        GPIO_079       PIN_MUX_11_27:24                      0xFFFF(0111/7)FFF
# Ethernet  LED1         AON_GPIO_05    PIN_MUX_0_23:19                       0xFFFFFF(1101/D)F
# Ethernet  LED2_1       AON_GPIO_09    PIN_MUX_1_07:04                       0xFFFFF(1101/D)FF
# Ethernet  LED2_2       AON_GPIO_11    PIN_MUX_1_15:12                       0xFFFFF(0111/7)FF

SUN_TOP_CTRL_PIN_MUX_CTRL_4=0xf0404110   # [GPIO_17:GPIO_24]
SUN_TOP_CTRL_PIN_MUX_CTRL_7=0xf040411c   # [GPIO_48:GPIO_41]
SUN_TOP_CTRL_PIN_MUX_CTRL_11=0xf040412c  # [GPIO_73:GPIO_80]
SUN_TOP_CTRL_PIN_MUX_CTRL_12=0xf0404130  # [GPIO_88:GPIO_81]
SUN_TOP_CTRL_PIN_MUX_CTRL_13=0xf0404134  # [GPIO_96:GPIO_89]
SUN_TOP_CTRL_PIN_MUX_CTRL_14=0xf0404138  # [SGPIO_01:SGPIO_00 && GPIO_102:GPIO_97]
GIO_IODIR_LO=0xf040a008      # [31:00]
GIO_DATA_LO=0Xf040a004       # [31:00]
GIO_IODIR_HI=0xf040a028      # [63:32]
GIO_DATA_HI=0Xf040a024       # [63:32]
GIO_IODIR_EXT_HI=0xf040a048  # [95:64]
GIO_DATA_EXT_HI=0Xf040a044   # [95:64]
GIO_IODIR_EXT2=0xf040a068    # [102:96]
GIO_DATA_EXT2=0Xf040a064     # [102:96]

AON_PIN_CTRL_PIN_MUX_CTRL_0=0xf0410700  # [AON_GPIO_07:AON_GPIO_00]
AON_PIN_CTRL_PIN_MUX_CTRL_1=0xf0410704# # [AON_GPIO_15:AON_GPIO_08]
GIO_AON_IODIR_LO=0xf0417008             # [19:00]
GIO_AON_DATA_LO=0xf0417004              # [19:00]


#MaskNumber=$((0xFFFFFF0F << 4))
#echo $MaskNumber

para=$1

function GPIO_PIN_MUX_Initialize() {
    TargetRegister=$1
    MaskNumber=$2
    val=`devmem $TargetRegister`   
    val=$(($val & $MaskNumber))              
    devmem $TargetRegister 32 $val 
}

function GPIO_IODIR_Initialize() {
    #SUPPORT SUN && AON 
    TargetRegister=$1
    MaskNumber=$2
    if [ $3 = "Input" ]; then     # SET"1"=input
        val=`devmem $TargetRegister`
        val=$(($val | $MaskNumber))  
        devmem $TargetRegister 32 $val  
    elif [ $3 = "Output" ]; then  # SET"0"=output
        val=`devmem $TargetRegister`
        val=$(($val & $MaskNumber))  
        devmem $TargetRegister 32 $val   
    fi
}

function GPIO_DATA(){
    TargetRegister=$1
    MaskNumber=$2
    if [ $3 = "H" ]; then 
        val=`devmem $TargetRegister`
        val=$(($val | $MaskNumber)) #SET"1" 
        devmem $TargetRegister 32 $val
    elif [ $3 = "L" ]; then 
        val=`devmem $TargetRegister`
        val=$(($val & $MaskNumber)) #SET"0"  
        devmem $TargetRegister 32 $val
    fi       
}


function flash_power_led() {
        status=$1
    
        PINMUX_MASK=0x00000000
        PINMUX_MASK_3=0x0000ffff
        PINMUX_MASK_4=0xff0fffff
        
        CM_TOP_CTRL_PIN_MUX_CTRL_0=0xd3880104
        CM_TOP_CTRL_PIN_MUX_CTRL_3=0xd388010c
        
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
            devmem 0xf0417004 32 0x000E2040 #WPS
            #devmem 0xf040a004 32 0xC0803000 #MoCA on
            val=`devmem $GPIO_DATA_31_00`
            val=$(($val | 0x00F00000))
            devmem $GPIO_DATA_31_00 32 $val
            
            val=`devmem $GPIO_PER_DATA_031_000`
            val=$(($val&0x00000000))
            devmem $GPIO_PER_DATA_031_000 32 $val

            GPIO_DATA $GIO_DATA_HI 0x00002000 H
            GPIO_DATA $GIO_DATA_EXT_HI 0x00028000 H
            GPIO_DATA $GIO_DATA_EXT2 0x00000008 H
            GPIO_DATA $GIO_AON_DATA_LO 0xFFFFFFDF L

            GPIO_DATA $GIO_AON_DATA_LO 0x00000200 H
            GPIO_DATA $GIO_AON_DATA_LO 0xFFFFF7FF L
            
            echo led on
        else #led_off
            devmem 0xf0417004 32 0x000E2240 #WPS
            #devmem 0xf040a004 32 0xC0003000 #MoCA off
            val=`devmem $GPIO_DATA_31_00`
            val=$(($val & 0xFF0FFFFF))
            devmem $GPIO_DATA_31_00 32 $val
            
            val=`devmem $GPIO_PER_DATA_031_000`
            val=$(($val|0xFFFFFFFF))
            devmem $GPIO_PER_DATA_031_000 32 $val

            GPIO_DATA $GIO_DATA_HI 0xFFFFDFFF L
            GPIO_DATA $GIO_DATA_EXT_HI 0xFFFD7FFF L
            GPIO_DATA $GIO_DATA_EXT2 0xFFFFFFF7 L
            GPIO_DATA $GIO_AON_DATA_LO 0x00000020 H

            GPIO_DATA $GIO_AON_DATA_LO 0xFFFFFDFF L
            GPIO_DATA $GIO_AON_DATA_LO 0x00000800 H
            
            echo led off
        fi
}


GPIO_PIN_MUX_Initialize $SUN_TOP_CTRL_PIN_MUX_CTRL_7 0xFFF0FFFF  # set 0000 GPIO Function
GPIO_PIN_MUX_Initialize $SUN_TOP_CTRL_PIN_MUX_CTRL_12 0xFFFFFFF0  
GPIO_PIN_MUX_Initialize $SUN_TOP_CTRL_PIN_MUX_CTRL_14 0xFFFFF0FF 
GPIO_PIN_MUX_Initialize $SUN_TOP_CTRL_PIN_MUX_CTRL_11 0xF0FFFFFF 
GPIO_PIN_MUX_Initialize $AON_PIN_CTRL_PIN_MUX_CTRL_0 0xFF0FFFFF 
GPIO_PIN_MUX_Initialize $AON_PIN_CTRL_PIN_MUX_CTRL_1 0xFFFFFF0F 
GPIO_PIN_MUX_Initialize $AON_PIN_CTRL_PIN_MUX_CTRL_1 0xFFFF0FFF 

GPIO_IODIR_Initialize $GIO_IODIR_HI 0xFFFFDFFF Output
GPIO_IODIR_Initialize $GIO_IODIR_EXT_HI 0xFFFD7FFF Output
GPIO_IODIR_Initialize $GIO_IODIR_EXT2 0xFFFFFFF7 Output
GPIO_IODIR_Initialize $GIO_AON_IODIR_LO 0xFFFFFFDF Output
GPIO_IODIR_Initialize $GIO_AON_IODIR_LO 0xFFFFFDFF Output 
GPIO_IODIR_Initialize $GIO_AON_IODIR_LO 0xFFFFF7FF Output # 0x00000800 0xFFFFF7FF


echo $para

if [ $para = "A" ]; then
    flash_power_led 1
elif [ $para = "B" ]; then 
    flash_power_led 0
else
    echo "please input A or B"
fi    
