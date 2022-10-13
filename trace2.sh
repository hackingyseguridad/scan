#!/bin/bash
# Script para testear ruta de forma masica
# Lee del fichero ip.txt la lista de IP
# Uso: sh trace2.sh
# (C) hackingyseguridad.com 2022
echo
for n in `cat ip.txt`; do echo $n; mtr -n -z -rw  $n; done
