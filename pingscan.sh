#!/bin/bash
echo
# Uso: sh pingscan.sh 192.168.1
echo
for x in `seq 1 254`; do
ping -c 1 $1.$x | grep "64 bytes" | cut -d" " -f4 | sed 's/.$//'
done
