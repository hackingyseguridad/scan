#!/bin/bash
# Script para rastrear rutas y escanerar los activos de los saltos que encuentra en la red
# Script para IPv4
# Lee del fichero ip.txt la lista de IP, entrega el resultado en el fichero resultado.txt
# Uso: sh rastreador.sh
# (C) hackingyseguridad.com 2023

echo
# Limpia de caracteres especiales el fichero de entrada ip.txt con direcciones IP IPv4
grep -Eo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" ip.txt > ips.txt

# Extrae IP de las rutas
for n in `cat ips.txt`; do echo $n; traceroute -A -n -d -N 64 $n; done > resultado1.txt

# filtra IP del resto de texto y caracteres y genera resutado2.txt
grep -Eo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" resultado1.txt > resultado2.txt

# Elimina IP duplicadas y genera resultado3.txt
awk '!visited[$0]++' "resultado2.txt" > resultado3.txt

# Escanea las IP que hemos obtenido y genera resultado.txt
nmap -iL resultado3.txt -Pn -sVC --open -p 21,22,23,80,443 -oG resultado.txt

