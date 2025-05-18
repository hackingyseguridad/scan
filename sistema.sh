#!/bin/bash
# Esaneo de sistema operativo y version.
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
        echo "Esaneo de puertos/servicios y vulnerabilidades conocidas."
        echo "Requiere nmap"
        echo "Uso.: sh vuln.sh <ip>"
        echo
        echo "\033[1;37mhttp://www.hackingyseguridad.com/\033[0m"
        exit 0
fi
echo
echo
echo "Escaneaabdo sistemas operativos...!"
echo
echo
nmap -Pn $1 $2 $3 -sV -p 445,135,139 --randomize-hosts -n -O --osscan-guess $0 -oG resultado.txt
echo
echo
echo "=======================RESUKTADO======================"
echo
cat resultado.txt






