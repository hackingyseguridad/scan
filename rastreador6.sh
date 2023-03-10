#!/bin/bash
# Script para rastrear rutas y escanerar los activos de los saltos que encuentra en la red
# Script para IPv6
# Lee del fichero ip.txt la lista de IP, entrega el resultado en el fichero resultado.txt
# Uso: sh rastreador.sh
# Version Beta
# (C) hackingyseguridad.com 2023

echo

# Extrae IP de las rutas
for n in `cat ip.txt`; do echo $n; traceroute -6 -A -n -d -N 99 $n; done > resultado1.txt

# filtra IP del resto de texto y caracteres y genera resutado2.txt
egrep '(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]).){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]).){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))' resultado1.txt > resultado2.txt

# Elimina IP duplicadas y genera resultado3.txt
awk '!visited[$0]++' "resultado2.txt" > resultado3.txt

# Escanea las IP que hemos obtenido y genera resultado.txt
nmap -6 -iL resultado3.txt -Pn -sVC --open -p 21,22,23,80,443 -oG resultado.txt
