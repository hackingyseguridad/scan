#!/bin/bash
# (c) hackingyseguridad.com 2023

cat << "INFO"

▬▬▬.◙.▬▬▬
═▂▄▄▓▄▄▂
◢◤ █▀▀████▄▄▄▄◢◤
█▄ █ █▄ ███▀▀▀▀▀▀▀╬
◥█████◤
══╩══╩═
╬═╬
╬═╬
╬═╬
╬═╬
╬═╬    resolver V.1.0
╬═╬    hackingyseguridad.com
╬═╬⛑/
╬═╬/▌
╬═╬/  \

INFO
echo
echo "..."
echo
for n in `cat subdominios.txt`
do
fqdn=$n
echo $fqdn && host $fqdn
done
