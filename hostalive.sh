#!/bin/bash
for n in `ip.txt`; do 
if ping -c 1 -W 1 "$n"; then
  echo "$n Up"
else
  echo "$n Down"
fi
done
