#!/bin/bash

# *.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*
# Author : Gavin Zhang
# Time   : 2018.0827
# Company: Foxconn-CNSBG-CPEGBBD-RD
# *.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*

boltenv -s WD_ENABLE "0"
num=0
while true  #main process
do
	echo "mtd0: \"flash1.rdknonvol\""
	nandtest -m /dev/mtd0
	echo "mtd1: \"flash1.kernel0\""   
	nandtest -m /dev/mtd1
	echo "mtd2: \"flash1.rg0\""
	nandtest -m /dev/mtd2
	echo "mtd3: \"flash1.kernel1\""
	nandtest -m /dev/mtd3
	echo "mtd4: \"flash1.rg1\""
	nandtest -m /dev/mtd4
	echo "mtd5: \"flash1.unused\""
	nandtest -m /dev/mtd5
	num=$[$num+1]
	echo "*.*.*.*.*.*.*.*.* > > > TEST $num TIME, FINISH ! < < < *.*.*.*.*.*.*.*.*"
	res=`date`
	echo "                                                TIME: $res"
	echo " "
	echo " "
done
