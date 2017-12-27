#!/bin/sh
# instalador suite escaneos
# Se instalaran as utilidades en /sbin/ para poder ser ejecutardo como comandos de Linux
chmod 777 scan.sh
apt-get install traceroute whois
apt-get install masscan
chmod 777 bgp2ip
chmod 777 ip2bgp
chmod 777 miip
chmod 777 tracebgp
chmod 777 scantcp
cp bgp2ip /sbin/
cp ip2bgp /sbin/
cp miip /sbin
cp tracebgp /sbin/
cp scantcp /sbin/
apt-get install nmap
git clone https://github.com/vulnersCom/nmap-vulners.git
echo
echo "Instalacion finalizada."
echo
