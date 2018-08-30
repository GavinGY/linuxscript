#!/bin/bash

# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*
#  > Author  ： Gavin | Zhang GuiYang
#  > Mail    ： gavin.gy.zhang@gmail.com
#  > Date    ： August/30/2018
#  > Company ： Foxconn·CNSBG·CPEGBBD·RD
#  > Funciton:  Phone Jack Port Voltage loop test
#  > Version :  v1.0 
#  > HowToUse:  tftp -g -r PhoneJackTest 192.168.0.11
#               chmod 777 PhoneJackTest
#               please input on / off / start
# *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*

function set_hight(){
    val=`devmem $GPIO_PER_DATA_063_032`
    val=$(($val | 0x00000400))             # 0xFFFFFFFF  # Tx/BNM_GPIO_042 ==> 3/8>"0100"/"4" 
    devmem $GPIO_PER_DATA_063_032 32 $val
    echo "1"
}

function set_low(){
    val=`devmem $GPIO_PER_DATA_063_032`
    val=$(($val & 0xFFFFFBFF))             # 0x00000000  # Tx/BNM_GPIO_042 ==> 3/8>"1011"/"B"
    devmem $GPIO_PER_DATA_063_032 32 $val
    echo "0"
}

function read_status(){
    val=`devmem $GPIO_PER_DATA_063_032`
    val=$(($val & 0x00000200))             # Rx/BNM_GPIO_041 ==> 3/8>"0010"/"2"
    if [ $val = 512 ]; then 
        echo "1"
    elif [ $val = 0 ]; then 
        echo "0"
    fi
}

function error_show(){
    echo "*.*.*.*.* >>> Phone Jack Port Test error !!!!"
    echo "Please check as follows:"
    echo "1. short circuit earphone insert or not ?"
    echo "2. hardware issue on the board.(component missing / no solder etc.) ?"
}

function Phone_jack_port() {

    # Green ==> Ring  ==>  PHONE_UART_Rx ==> SOIC_UART_Rx ==> W40 ==> BNM_GPIO_041/BNM_UART_RXD_1/BNM_DIAG_36
    # Red   ==> Tip   ==>  PHONE_UART_Tx ==> SOIC_UART_Tx ==> W41 ==> BNM_GPIO_042/BNM_UART_TXD_1/BNM_DIAG_37
    # PIN_MUX Register:  BNM_GPIO_041 ==> CM_TOP_CTRL_PIN_MUX_CTRL_6 07:04
    #                    BNM_GPIO_042 ==> CM_TOP_CTRL_PIN_MUX_CTRL_6 08:11
    # PIN_DIR Register:  //GIO_IODIR_HI[63:32] 0xf040a028 ==> ARM GPIO
    #                    BNM_GPIO_041/BNM_GPIO_042 ==> GPIO_PER_DIR_063_032[63:32]  0xd3c00504 ==> MIPS GPIO
    # PIN_DATA Register: //GIO_DATA_HI[63:32] 0xf040a024 ==> ARM GPIO
    #                    BNM_GPIO_041/BNM_GPIO_042 ==> GPIO_PER_DATA_063_032[63:32] 0xd3c0052c ==> MIPS GPIO
    
    CM_TOP_CTRL_PIN_MUX_CTRL_6=0xd3880118      # PIN_MUX Physical Address
    GPIO_PER_DIR_063_032=0xd3c00504            # PIN_DIR Physical Address   MIPS GPIO ("BNM")
    # GIO_IODIR_HI=0xf040a028                  # PIN_DIR Physical Address   ARM GPIO
    GPIO_PER_DATA_063_032=0xd3c0052c           # PIN_DATA Physical Address  MIPS GPIO ("BNM")
    # GIO_DATA_HI=0xf040a024                   # PIN_DATA Physical Address  ARM GPIO

    
    val=`devmem $CM_TOP_CTRL_PIN_MUX_CTRL_6`   # read CM_TOP_CTRL_PIN_MUX_CTRL_6
    # Set 3/8 2/8 value "0000" | BNM_GPIO_041 ==> 07:04 | BNM_GPIO_042 ==> 08:11 ==> GPIO function
    val=$(($val & 0xFFFFF00F))                 # 0x00000000 
    devmem $CM_TOP_CTRL_PIN_MUX_CTRL_6 32 $val # Write setting Value

	val=`devmem $GPIO_PER_DIR_063_032`         # read GPIO_PER_DIR_063_032 Value
	# Set value "1" ==> output [BNM_GPIO "1"==>Output "0"==>Input] Tx/BNM_GPIO_042 ==> 3/8>"0100"/"4"
	val=$(($val | 0x00000400))                 # 0xFFFFFFFF  
	devmem $GPIO_PER_DIR_063_032 32 $val       # write GPIO_PER_DIR_063_032

    val=`devmem $GPIO_PER_DIR_063_032`         # read GPIO_PER_DIR_063_032 Value
    # Set value "0" ==> input  [BNM_GPIO "1"==>Output "0"==>Input] Rx/BNM_GPIO_041 ==> 3/8>"1101"/"D"
    val=$(($val & 0xFFFFFDFF))                 # 0xFFFFFFFF
    devmem $GPIO_PER_DIR_063_032 32 $val       # write GPIO_PER_DIR_063_032
	
	status=$1
    error_status=0
    # set value "1"
    if [ $status = 1 ]; then 
	    val=`set_hight`
        echo "Tip  PHONE_UART_Tx Send value:    $val"
    # set value "0"
    elif [ $status = 0 ]; then 
        val=`set_low`
        echo "Tip  PHONE_UART_Tx send value:    $val"
    # loop test.
    elif [ $status = 2 ]; then 
        echo "*.*.*.*.* >>> Phone Jack Port Voltage loop test start <<< *.*.*.*.*"
        res=`set_hight`
        b=''
        for ((i=0;$i<=100;i+=2))
        do
            printf "Progress:[%-50s]%d%%\r" $b $i
            val=`read_status`
            if [ $val = $res ]; then 
                b=#$b
            else
                error_status=1
                break
            fi
            usleep 10000  
            if [ $res = 1 ]; then 
                res=`set_low`
            elif [ $res = 0 ]; then 
                res=`set_hight`
            fi
            usleep 10000
        done
        echo
        if [ $error_status = 0 ]; then 
            echo "*.*.*.*.* >>> Phone Jack Port Test Pass !"
        else
            error_show
        fi
    fi

    if [ $status -lt 2 ]; then 
        sleep 1
        val=`read_status`
        echo "Ring PHONE_UART_Rx Receive value: $val"
        # val=`devmem $GPIO_PER_DATA_063_032`
        # val=$(($val & 0xFFFFFDFF))                 # Data clear"0" ==> Rx/BNM_GPIO_041 ==> 3/8>"1101"/"D"
        # devmem $GPIO_PER_DATA_063_032 32 $val
    fi
}


if [ $1 = "on" ]; then
    Phone_jack_port 1
    #echo hello-gavin led on
elif [ $1 = "off" ]; then 
    Phone_jack_port 0
    #echo hello-gavin led off
elif [ $1 = "start" ]; then 
    Phone_jack_port 2
    #echo hello-gavin led off
else
    echo "please input on / off / start "
fi     




