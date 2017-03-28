#!/bin/bash
read -p opcion
case $opcion in
0) echo " " ;;
1) nmap -iL ip.txt -Pn -f --open -sU -sS -sC -sV -O --max-retries 1 -p 53 -oG resultado.txt;; 
2) echo "2";;
3) echo "3";;
*) echo "uso: ./scan.sh"
echo "Fichero: ip.txt listado IP/rangos a escanear"
echo "Fichero: resultado.txt se genera al finalizar"
echo "Pulsa opcion escaneo UDP/TCP: 0 - 9: echo "1) rapido 100 puertos, 2) normal 1000 puertos, 3) completo 65536 puertos, 0) Salir";;
esac
