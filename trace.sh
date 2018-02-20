#!/bin/bash
# Script para testear ruta
# Lee del fichero ip.txt la lista de IP
# Uso: sh trace.sh
# (C) hackingyseguridad.com 2017
echo
DATE=`date +%Y%m%d`
for n in `cat ip.txt`; do echo $n; traceroute -A $n; done
service networking restart
