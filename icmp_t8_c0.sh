#
# Scrips para ver si hay respuesta Echo Request ICMP type 8 Cpde 0
# 2022 hackingyseguridad.com
#
nping --icmp --icmp-type 8 time --delay 500ms $1
nmap -PE $1
