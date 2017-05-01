#!/bin/bash
# Version Beta (c) Antonio Taboada 2017
echo "###############################################################"
echo "# Script para escaneos de puertos con Nmap: (http://nmap.org) #"
echo "# En modo consola dar permisos de ejecucion: chmod +x scan.sh #"
echo "# Ejecutar en consola con privilegios de SuperUser: ./scan.sh #"
echo "# Incluir en la misma carpeta con rangos IP a scanear: ip.txt #"
echo "# Al finalizar se generara en la misma carpeta: resultado.txt #"
echo "###############################################################"
echo
echo "1) Rapido: 100 puertos udp/tcp"
echo "2) Normal: 1000 puertos udp/tcp"
echo "3) Completo: 65535 puertos udp/tcp"
echo "f) Saltar firewall"
echo "4) NTP"		
echo "5) DNS"
echo "6) IPv6"
echo "7) SNMP"
echo "8) Telnet"
echo "9) SSH"
echo "w) Netbios, SMB"
echo "h) http"
echo "p) Solo Ping"
echo "t) Traceroute"
echo "0) Salir"
echo "Pulsa opcion del tipo de escaneo UDP/TCP: 0 - 9:"; read x
case $x in
1)
echo ""; nmap -iL ip.txt --open -sUT --max-retries 1 -F -O -oG resultado.txt; tail resultado.txt
;;
2)
echo ""; nmap -iL ip.txt -Pn --open -sUTCV -O --max-retries 1 -oG resultado.txt; tail resultado.txt
;;
3)
echo ""; nmap -iL ip.txt -Pn --open -sUTCV -O --max-retries 1 -p 0-65535 -oG resultado.txt; tail resultado.txt
;;
f)
echo ""; nmap -iL ip.txt -Pn -g0 --open -sUSCV -O --max-retries 1 -p 0-65535 --script firewall-bypass -oG resultado.txt; tail resultado.txt
;;
4)
echo ""; nmap -iL ip.txt -Pn --open -sUTCV -O --max-retries 1 -p123 --script ntp-monlist -oG resultado.txt; tail resultado.txt
;;
5)
echo ""; nmap -iL ip.txt -Pn --open -sUTCV -O --max-retries 1 -p53 --script dns-recursion -oG resultado.txt; tail resultado.txt
;;
6)
echo ""; nmap -iL ip.txt -6 -Pn --open -sUTCV -O --max-retries 1 -oG resultado.txt; tail resultado.txt
;;
7)
echo ""; nmap -iL ip.txt -Pn --open -sUTCV -O --max-retries 1 -p161 --script snmp-info -oG resultado.txt; tail resultado.txt
;;
8)
echo ""; nmap -iL ip.txt -Pn --open -sTCV -O -p23 -oG resultado.txt; tail resultado.txt
;;
9)
echo ""; nmap -iL ip.txt -Pn --open -sTCV -O -p22,2222 -oG resultado.txt; tail resultado.txt
;;
w)
echo ""; nmap -iL ip.txt -Pn --open -sUTCV -O --max-retries 1 -p137,138,139,445 -oG resultado.txt; tail resultado.txt
;;
h)
echo ""; nmap -iL ip.txt -Pn --open -sTCV -O --max-retries 1 -p80,443 --script http-enum -oG resultado.txt; tail resultado.txt
;;
p)
echo ""; nmap -iL ip.txt -sn -oG resultado.txt; tail resultado.txt
;;
t)
echo ""; nmap -iL ip.txt -Pn --open --traceroute > resultado.txt
;;
*)
echo "Opcion no valida!"
;;
esac
