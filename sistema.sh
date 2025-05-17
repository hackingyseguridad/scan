#!/bin/sh
echo "\033[1;37mhackingyseguridad.com\033[0m"
#
#  
#
echo 
echo
echo "Escanea sistemas operativos...!"
echo 
echo
nmap -Pn $1 $2 $3 -p 135,139,445 --randomize-hosts --max-retries 1 -n --open -O --script=banner -oN resultado.txt
echo
echo
echo "= RESUMEN ==================================================================="
echo
sed -n '
  /Nmap scan report for/ { s/.*for //; h }
  /Aggressive OS guesses:/ {
    s/.*: //; s/(.*)//g; s/,.*//;
    H; g; s/\n/ /; p
  }
' resultado.txt 






