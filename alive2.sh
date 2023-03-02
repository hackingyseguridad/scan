#!/bin/sh
# Escaneo rapido para ver activos IP con respuesta ping
# hacking y seguridad 2023
# nmap -iL ip.txt -sn -n  -e wlan0
nmap -iL ip.txt -sn -n --randomize-hosts 
