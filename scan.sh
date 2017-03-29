#!/bin/bash
echo "#	#########################################################	#"
echo "#	Script para escaneos ./scan.sh					#"
echo "#	Incluir en misma carpeta ip.txt con rangos a escanear		#"
echo "#	Generara automaticamente misma carpeta resultado.txt		#"
echo "#	Pulsa opcion del tiopo de escaneo UDP/TCP: 0 - 9:		#"
echo "#	1) Rapido, 2) Normal, 3) Completo 65536p, 4) IPv6		#"
echo "#	4) 5) DNS, 6) NTP, 7) SNMP, 8) Telnet, 9) SSH, 0) Salir		#"
echo "#	#########################################################	#"
echo 
read x
case $x in
1)
echo ""; nmap -iL ip.txt --open -sU -sT --max-retries 1 -F -oG resultado.txt; tail resultado.txt
;;
2)
echo ""; nmap -iL ip.txt -Pn --open -sU -sT -sC -sV -O --max-retries 1 -oG resultado.txt
;;
3)
echo ""; nmap -iL ip.txt -Pn --open -sU -sT -sC -sV -O --max-retries 1 -p 0-65535 -oG resultado.txt
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
*)
echo "Opcion no valida!"
;;
esac
