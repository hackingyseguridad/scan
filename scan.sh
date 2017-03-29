#!/bin/bash
echo "Ejecutar en consola: sh scan.sh"
echo "Incluir en la misma carpeta fichero ip.txt con las IP o rangos a escanear"
echo "Se generara automaticamente en la misma carpeta el fichero resultado.txt"
echo "Pulsa opcion escaneo UDP/TCP: 0 - 9:"
echo "1) Rapido 100p, 2) Normal 1000 p, 3) Completo 65536 p, 0) Salir"
read x
case $x in
1)
echo ""; nmap -iL ip.txt -Pn -f --open -sU -sT -sC -sV -O --max-retries 1 -F -oG resultado.txt
;;
2)
echo ""; nmap -iL ip.txt -Pn -f --open -sU -sT -sC -sV -O --max-retries 1  -oG resultado.txt
;;
3)
echo ""; nmap -iL ip.txt -Pn -f --open -sU -sT -sC -sV -O --max-retries 1 -p 0-65535 -oG resultado.txt
;;
*)
echo "Opcion no valida!"
;;
esac
