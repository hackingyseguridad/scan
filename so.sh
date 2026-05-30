#!/bin/sh
# Esaneo de sistema operativo y version.
# @antonio_taboada  2026
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
nmap -Pn -F "$1" $2 $3 --open -sV -O --osscan-guess --defeat-rst-ratelimit -oN resultado.txt -v0

echo "============================================================"
echo "IP/HOST             | SISTEMA OPERATIVO / KERNEL"
echo "============================================================"

awk '
/Nmap scan report for/ {
    if (host != "" && info != "") printf "%-18s | %s\n", host, info
    host = $5; gsub(/[()]/, "", host)
    info = ""
}
/OS details/ && info == "" { info = substr($0, index($0,":")+2); sub(/^ /,"",info) }
/Running:.*Linux/ && info == "" { info = substr($0, index($0,"R")); sub(/^ /,"",info) }
/Linux [0-9]+\.[0-9]+/ && info == "" {
    match($0, /Linux [0-9]+\.[0-9]+/); info = substr($0, RSTART, RLENGTH)
}
/Windows/ && info == "" {
    match($0, /Windows[^,]+/); info = substr($0, RSTART, RLENGTH)
}
END { if (host != "" && info != "") printf "%-18s | %s\n", host, info }
' resultado.txt

echo "============================================================"
echo




