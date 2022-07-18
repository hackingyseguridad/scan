#!/bin/bash
printf "Ver puertos abiertos en local: - "&& printf "\e[1;34mwww.hackingyseguridad.com\e[0m"
# Ejecutar en remoto desde Github: 
# wget -O - https://raw.githubusercontent.com/hackingyseguridad/scan/master/local.sh  | bash
# wget -O - https://raw.githubusercontent.com/hackingyseguridad/scan/master/local.sh  | zsh
# curl -sL  https://raw.githubusercontent.com/hackingyseguridad/scan/master/local.sh |bash
# curl -sL  https://raw.githubusercontent.com/hackingyseguridad/scan/master/local.sh |zsh
echo 
echo "###############################################################################################"
ss -tulnp
echo "###############################################################################################"
netstat -pnltu
echo "###############################################################################################"
lsof -i
echo "###############################################################################################"
nmap -Pn -sTU --open localhost
echo "###############################################################################################"



