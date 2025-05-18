#!/bin/sh
#
#
#
#
echo
echo
echo "\033[1;37mhttp://www.hackingyseguridad.com/\033[0m"
echo
echo
echo "Escanea sistemas operativos...!"
echo
echo
nmap -Pn $1 $2 $3  -sV -F --randomize-hosts -n -O --osscan-guess $0 -oN resultado.txt | sed -n '
/Nmap scan report for/ {h}
/OS details\|Aggressive OS guesses/ {x;G;s/\n/: /;p}
'
echo
echo
# echo "= RESUMEN ==================================================================="
echo
'





