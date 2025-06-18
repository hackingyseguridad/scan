#!/bin/sh
# Escaneo rapido IPv6
# (c) hackingyseguridad.com 2025
# Uso: ./scanipv6.sh
# 
#
#
nmap -6 -e eth0 -Pn 2a02:9000::/23 --open -n -p 22 --min-rate 5000  -oG resultado.txt
