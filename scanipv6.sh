#!/bin/sh
# Escaneo rapido IPv6
# http://www.hackingyseguridad.com  - 2025
# Uso: ./scanipv6.sh
# -min-rate 9999 , abre 10000 hilos
# 
# 
nmap -6 -e eth0 -Pn 2a02:9000::/23 --open -n -p 22 --min-rate 9999 -oG resultado.txt
