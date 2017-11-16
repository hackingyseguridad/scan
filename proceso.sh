#!/bin/bash
echo "Ejecuta escaneo de puertos como un proceso de Linux"
echo "ps -ALL |grep nmap"
echo "Uso.: sh proceso.sh IP"
nmap $1 $2 -Pn -sUVCT -F -iL ip.txt --open -oG resultado.txt &exit
