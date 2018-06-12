# Escanea listadp de IP o fqdn en fichero "ip.txt"
# (c) 2018 hackingyseguridad.com

#!/bin/bash
echo "Uso.: ./scanport.sh <Puerto_TCP>"
for n in `cat ip.txt`
do
        if nc -zv $n $1 -w 1 > /dev/null 2>&1; then echo $n ":" $1 "open"; fi
done
