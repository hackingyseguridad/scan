#!/bin/sh
# Escaneo rapido para ver activos IP con respuesta ping
# hacking y seguridad 2023
# 

masscan -iL ip.txt --rate 9999 --ping -n --randomize-hosts -v -e wlan0
