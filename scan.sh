#!/bin/bash
echo ""
echo "uso: ./scan.sh"
echo "Fichero: ip.txt listado IP/rangos a escanear"
echo "Fichero: resultado.txt se genera al finalizar"
echo ""
echo "Pulsa opcion escaneo UDP/TCP: 0 - 9:"
echo "1) rapido 100 puertos"
echo "2) normal 1000 puertos"
echo "3) completo 65536 puertos"
echo "0) Salir"
echo ""
read -p opcion
case $opcion in
0) echo " " ;;
1) nmap -iL ip.txt -Pn -f --open -sU -sS -sC -sV -O --max-retries 1 -p 53 -oG resultado.txt;; 
2) echo "2";;
3) echo "3";; 
4) echo "4";;
5) echo "5";;
6) echo "6";;
*) echo "Pulsa (0-9)";;
esac
echo