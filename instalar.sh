#!/bin/sh
# instalador suite escaneos
# Se instalaran as utilidades en /sbin/ para poder ser ejecutardo como comandos de Linux
chmod 777 scan.sh
apt-get install traceroute whois
chmod 777 bgp2ip
chmod 777 ip2bgp
chmod 777 miip
chmod 777 tracebgp
cp bgp2ip /sbin/
cp ip2bgp /sbin/
cp miip /sbin
cp tracebgp /sbin/
apt-get install nmap
git clone https://github.com/glennzw/shodan-hq-nse
cp shodan-hq-nse/shodan-hq.nse /usr/local/share/nmap/scripts/
