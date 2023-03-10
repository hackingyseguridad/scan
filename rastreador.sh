#!/bin/bash
# Script para rastrear todas las rutas y scanerar todos los activos de los saltos
# Lee del fichero ip.txt la lista de IP
# Uso: sh rastreador.sh
# (C) hackingyseguridad.com 2023
echo
for n in `cat ip.txt`; do echo $n; traceroute -A -n -d -N 99 $n; done > resultado.txt
grep -Eo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" resultado.txt > resultado2.txt
awk '!visited[$0]++' "resultado2.txt" > resultado3.txt
nmap -iL resultado3.txt -Pn -sVC --open -p 21,22,23,80,443 -oG resultado4.txt
