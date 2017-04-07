#!/bin/bash
# Version Beta (c) hackingyseguridad.com 2017
echo "###############################################################"
echo "# Script para escaneos de puertos con Nmap: (http://nmap.org) #"
echo "# En modo consola dar permisos de ejecucion: chmod +x scan.sh #"
echo "# Ejecutar en consola con privilegios de SuperUser: ./scan.sh #"
echo "# Incluir en la misma carpeta con rangos ip a ecanear: ip.txt #"
echo "# Al finalizar se generara en la misma carpeta: resultado.txt #"
echo "###############################################################"
echo
echo "1) Rapido: 100 puertos udp/tcp"
echo "2) Normal: 1000 puertos udp/tcp"
echo "3) Completo: 65535 puertos"
echo "f) Saltar firewall"
echo "4) IPv6"		
echo "5) DNS"
echo "6) NTP"
echo "7) SNMP"
echo "8) Telnet"
echo "9) SSH"
echo "p) Solo Ping"
echo "s) TCP SYM connect
echo "0) Salir"
echo "Pulsa opcion del tiopo de escaneo UDP/TCP: 0 - 9:"; read x
case $x in
1)
echo ""; nmap -iL ip.txt --open -sU -sT --max-retries 1 -F -O -oG resultado.txt; tail resultado.txt
;;
2)
echo ""; nmap -iL ip.txt -Pn --open -sU -sT -sC -sV -O --max-retries 1 -oG resultado.txt
;;
3)
-echo ""; nmap -iL ip.txt -Pn --open -sU -sT -sC -sV -O --max-retries 1 -p 0-65535 -oG resultado.txt
;;
f)
echo ""; nmap -iL ip.txt -Pn -g0 --open -sU -sS -sC -sV -O --max-retries 1 -p 0-65535 --script firewall-bypass -oG resultado.txt
;;
4)
echo ""; nmap -iL ip.txt -6 -Pn --open -sU -sT -sC -sV -O --max-retries 1 -oG resultado.txt
;;
5)
echo ""; nmap -iL ip.txt -Pn --open -sU -sT -sC -sV -O --max-retries 1 -p53 -oG resultado.txt
;;
6)
echo ""; nmap -iL ip.txt -Pn --open -sU -sT -sC -sV -O --max-retries 1 -p123 --script ntp-monlist -oG resultado.txt
;;
7)
echo ""; nmap -iL ip.txt -Pn --open -sU -sT -sC -sV -O --max-retries 1 -p161 -oG resultado.txt
;;
8)
echo ""; nmap -iL ip.txt -Pn --open -sU -sT -sC -sV -O --max-retries 1 -p23 -oG resultado.txt
;;
9)
echo ""; nmap -iL ip.txt -Pn --open -sU -sT -sC -sV -O --max-retries 1 -p22 -oG resultado.txt
;;
p)
echo ""; nmap -iL ip.txt -sn -oG resultado.txt; tail resultado.txt
;;
s)
echo ""; nping --tcp-connect rate=999 -c 100 194.224.175.76 -p 80 
;;
*)
echo "Opcion no valida!"
;;
esac
