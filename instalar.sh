#!/bin/sh
# instalador como comando de tracebgp
# Se instalara en /sbin/ para poder ser ejecutardo como un comando de Linux
chmod 777 scan.sh
apt-get install traceroute whois
git clone https://github.com/glennzw/shodan-hq-nse
cp shodan-hq.nse /usr/local/share/nmap/scripts/
chmod 777 bgp2ip
chmod 777 ip2bgp
chmod 777 miip
chmod 777 tracebgp
cp bgp2ip /sbin/
cp ip2bgp /sbin/
cp miip /sbin
cp tracebgp /sbin/
apt-get install nmap
