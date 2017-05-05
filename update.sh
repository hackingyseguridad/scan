#!/bin/bash
# Actualiza solo el script bash. Version Beta (c) Antonio Taboada 2017
wget https://raw.githubusercontent.com/hackingyseguridad/scan/master/scan.sh
cp scan.sh.1 scan.sh
chmod 777 scan.sh
apt-get upgrade nmap
