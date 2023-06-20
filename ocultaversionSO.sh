#!/bin/bash
# Script para ocultar la version del SO Linux 
# 
# Uso: sh ocultaversionSO.sh
# (C) hackingyseguridad.com 2023
echo
echo "Ocultar la versión del SO, fingerprint, Sistema Operativo Linux utilizado con el tamaño del TTL"
echo 
echo
echo "Device/OS	TTL"
echo "==================="
echo "(Linux/Unix)	64"
echo "Windows		128"
echo "Solaris/AIX	254"
echo 
echo "Ctrol + C para interrumpir"
echo
pause
echo
echo "Modifica el TTL a 129, por defecto Kali Linux es 64"
sudo sysctl -w net.ipv4.ip_default_ttl=129
echo "."
echo ".."
echo "..."
echo "Ok!"
echo "Ver el fichero /proc/sys/net/ipv4/ip_default_ttl "
cat /proc/sys/net/ipv4/ip_default_ttl
