#!/bin/bash
# Script para ver respuesta a ND en IPv6, ICMP type 135
# Lee del fichero ipv6.txt la lista de IP
# Uso: sh ndisc7.sh
# Version Beta
# (C) hackingyseguridad.com 2023

echo

# Extrae IP de ipv6.txt y prueba cada IP a respuesta ND
for n in `cat ipv6.txt`; do echo $n; ndisc6  $n wlo1; done
