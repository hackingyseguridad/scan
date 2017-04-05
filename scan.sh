#!/bin/bash
##############################################################
# Menu para escaneos de puertos con Nmap (http://nmap.org)
# Version Beta (c) Antonio Taboada 04/04/2017
# Requiere privilegios de Super User
# En modo consola dar permisos de ejecucion: chmod 777 scan.sh
# Ejecutar en modo consola: ./scan.sh
##############################################################
echo "Script para escaneos con Nmap (https://nmap.org)"
echo "Uso: sh scan.sh"			
echo "Incluir en misma carpeta ip.txt con rangos a escanear"		
echo "Generara automaticamente misma carpeta resultado.txt"
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
echo "0) Salir"		
echo "Pulsa opcion del tiopo de escaneo UDP/TCP: 0 - 9:"; read x
case $x in
1)
echo ""; nmap -iL ip.txt --open -sU -sT --max-retries 1 -F -oG resultado.txt; tail resultado.txt
;;
2)
echo ""; nmap -iL ip.txt -Pn --open -sU -sT -sC -sV -O --max-retries 1 -oG resultado.txt
;;
3)
echo ""; nmap -iL ip.txt -Pn --open -sU -sT -sC -sV --osscan-guess --max-retries 1 -p 0-65535 -oG resultado.txt
;;
f)
echo ""; nmap -iL ip.txt -Pn -g0 --open -sU -sS -sC -sV -O --max-retries 1 -p 0-65535 -oG resultado.txt
;;
4)
echo ""; nmap -iL ip.txt -6 -Pn --open -sU -sT -sC -sV -O --max-retries 1 -oG resultado.txt
;;
5)
echo ""; nmap -iL ip.txt -Pn --open -sU -sT -sC -sV -O --max-retries 1 -p53 -oG resultado.txt
;;
6)
echo ""; nmap -iL ip.txt -Pn --open -sU -sT -sC -sV -O --max-retries 1 -p123 -oG resultado.txt
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
echo ""; nmap -iL ip.txt -sn -oG resultado.txt
;;
*)
echo "Opcion no valida!"
;;
esac
