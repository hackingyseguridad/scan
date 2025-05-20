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
        echo "Esaneo de sistema operativo y version."
        echo "Requiere nmap"
        echo "Uso.: sh so.sh <ip>"
        echo
        echo "\033[1;37mhttp://www.hackingyseguridad.com/\033[0m"
        exit 0
fi
echo
echo "Escaneaabdo sistemas operativos...!"
echo

nmap -Pn -F $1 $2 $3 --open -sV -O --osscan-guess $0 




