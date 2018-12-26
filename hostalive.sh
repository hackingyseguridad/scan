#!/bin/bash
# for i in {1..254};do (ping -c1 192.168.0.$i & done
for n in `cat ip.txt`
do

if ping $n -c 1 -W 1 > /dev/null
then echo $n "up"
else echo $n "down"
fi

done
