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
echo "u) Ultra rapido: puertos udp/tcp"
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
echo "m) smtp"
echo "n) ssdp"
echo "p) Solo Ping"
echo "i) Resolucion inversa"
echo "e) ftp"
echo "r) RDP"
echo "s) Broadcast"
echo "t) Traceroute"
echo "x) Tor TCP"
echo "0) Salir"
echo "Pulsa opcion del tipo de escaneo UDP/TCP: 0 - 9:"; read x
case $x in
u)
echo ""; masscan --rate 9999999999 -iL ip.txt -sS --open-only -n -p0-65535 --ports U:0-65535 -oG resultado.txt; tail resultado.txt
;;
1)
echo ""; nmap -iL ip.txt -Pn --open -sUT --max-retries 1 -F -O -oG resultado.txt; tail resultado.txt
;;
2)
echo ""; nmap -iL ip.txt -Pn --open -sUTCV -O --max-retries 1 -oG resultado.txt; tail resultado.txt
;;
3)
echo ""; nmap -iL ip.txt -Pn --open -sUTCV -O --max-retries 1 -p 0-65535 -oG resultado.txt; tail resultado.txt
;;
f)
echo ""; nmap -iL ip.txt -Pn -g0 --open -sUSCV -O --max-retries 1 -p 0-65535 --defeat-rst-ratelimit --script firewall-bypass -oG resultado.txt; tail resultado.txt
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
echo ""; nmap -iL ip.txt -Pn --open -sCV -O -p23 -oG resultado.txt; tail resultado.txt
;;
9)
echo ""; nmap -iL ip.txt -Pn --open -sCV -O -p22,2222 -oG resultado.txt; tail resultado.txt
;;
w)
echo ""; nmap -iL ip.txt -Pn --open -sUTCV -O --max-retries 1 -p137,138,139,445 -oG resultado.txt; tail resultado.txt
;;
h)
echo ""; nmap -iL ip.txt -Pn -p80,443 --script http-enum --open -sCV -O -oG resultado.txt; tail resultado.txt
;;
m)
echo ""; nmap -iL ip.txt -Pn -p25 --script=smtp* -sCV -O --open -oG resultado.txt; tail resultado.txt
;;
n)
echo ""; nmap -iL ip.txt -Pn -sUCV -p1900 --max-retries 1 --open -oG resultado.txt; tail resultado.txt
;;
p)
echo ""; nmap -iL ip.txt -sn -oG resultado.txt; tail resultado.txt
;;
i)
echo ""; nmap -iL ip.txt -sL -R --dns-servers 194.179.1.100 -oG resultado.txt; tail resultado.txt
;;
e)
echo ""; nmap -iL ip.txt -Pn --open -sCV -O -p21 -oG resultado.txt; tail resultado.txt
;;
r)
echo ""; nmap -iL ip.txt -Pn --open -sCV -O -p3389 -oG resultado.txt; tail resultado.txt
;;
s)
echo ""; nmap -iL ip.txt -Pn --script=broadcast* --script-args=newtargets -sCV -O --open -oG resultado.txt; tail resultado.txt
;;
t)
echo ""; nmap -iL ip.txt -Pn --open --traceroute > resultado.txt
;;
x)
echo ""; OIFS=$IFS; IFS=$'\n'; service tor start; proxychains nmap -iL ip.txt --open -sVC -O -oG resultado.txt
;;
*)
echo "Opcion no valida!"
;;
esac
