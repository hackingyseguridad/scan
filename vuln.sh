#!/bin/bash
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
        exit 0
fi
echo
echo
nmap -Pn $1 $2 $3 $4 $5 -sVC -O --script=default,banner,vuln,vulners --script-args mincvss=7 -p- --open
