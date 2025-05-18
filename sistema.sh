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
echo "Escaneaabdo sistemas operativos...!"
echo
nmap -Pn $1 $2 $3 -F --randomize-hosts -n -O --osscan-guess $0 -oG resultado.txt
echo
echo "======================= RESULTADO ========================="
echo
cat resultado.txt | awk '
/Host:/ {ip=$2}
/OS:/ {print ip ": " substr($0, index($0, "OS:")+3)}
'
echo







