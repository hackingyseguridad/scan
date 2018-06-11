#!/bin/bash
for n in `ip.txt`; do 
if ping -c 1 -W 1 "$n"; then
  echo "$hostname_or_ip_address is alive"
else
  echo "$hostname_or_ip_address is pining for the fjords"
fi
nc -zv $n 80 443 -w 1; done
