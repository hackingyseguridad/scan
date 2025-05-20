#!/bin/bash
# Esaneo de sistema operativo y version.
# (R) Antonio Taboada, 2025
echo
cat << "INFO"

(:`--..___...-''``-._             |`._
  ```--...--.      . `-..__      .`/ _\
            `\     '       ```--`.    />
            : :   :               `:`-'
             `.:.  `.._--...___     ``--...__
                ``--..,)       ```----....__,)   http://www.hackingyseguridad.com

INFO
if [ -z "$1" ]; then
        echo
        echo "Esaneo de sistema operativo y version. - 2 -"
        echo "Requiere nmap"
        echo "Uso.: sh sistema2.sh <ip>"
        echo
        echo "\033[1;37mhttp://www.hackingyseguridad.com/\033[0m"
        exit 0
fi
echo
echo "Escaneaabdo sistemas operativos...!"
echo
nmap -Pn $1 $2 $3 -F --randomize-hosts -n -O --osscan-guess $0 -oN resultado.txt
echo
echo "======================= RESULTADO ========================="
echo
 grep -E -A10 "Nmap scan report for|Running \(JUST GUESSING\):|Aggressive OS guesses:" resultado.txt | awk '                                                                             
  /Nmap scan report for/ { ip = $5 }
  /Running \(JUST GUESSING\):/ { print ip, $0; next }
' | sed 's/Nmap scan report for //; s/Running (JUST GUESSING): //;'



echo
echo





grep -E -A10 "Nmap scan report for|Running \(JUST GUESSING\):|Aggressive OS guesses:" resultado.txt | awk '
  /Nmap scan report for/ { ip = $5 }
  /Running \(JUST GUESSING\):/ { print ip, $0; next }
  /Aggressive OS guesses:/ && !/Running/ { print ip, $0 }
' | sed 's/Nmap scan report for //; s/Running (JUST GUESSING): //; s/Aggressive OS guesses: //'
