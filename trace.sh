#!/bin/bash
# Script para testear ruta
# Lee del fichero ip.txt la lista de IP
# Uso: sh trace.sh
# (C) hackingyseguridad.com 2023
echo
for n in `cat ip.txt`; do echo $n; traceroute -A -n -d -N 99 $n; done
