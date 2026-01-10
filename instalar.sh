#!/bin/sh
# instalador suite escaneos
# Se instalaran as utilidades en /sbin/ para poder ser ejecutardo como comandos de Linux
chmod 777 scan.sh
wget https://github.com/OCSAF/freevulnsearch/blob/master/freevulnsearch.nse
cp freevulnsearch.nse /usr/share/nmap/scripts/
apt-get install traceroute whois
apt-get -y install libpcap-dev
apt-get -y install masscan
chmod 777 bgp2ip
chmod 777 ip2bgp
chmod 777 ip2pais
chmod 777 miip
chmod 777 miip2
chmod 777 tracebgp
chmod 777 scantcp
cp bgp2ip /sbin/
cp ip2bgp /sbin/
cp ip2pais /sbin/
cp miip /sbin/
cp miip2 /sbin/
cp tracebgp /sbin/
cp scantcp /sbin/
apt-get install nmap
git clone https://github.com/vulnersCom/nmap-vulners.git
git clone https://github.com/scipag/vulscan scipag_vulscan
ln -s `pwd`/scipag_vulscan /usr/share/nmap/scripts/vulscan
echo

# Script para instalar RustScan
# rustscan --addresses 192.168.1.0/24 -t 500 -b 1500 -- -A

# git clone https://github.com/RustScan/RustScan.git
# cd RustScan
# apt-get install cargo
# cargo build --release
# cp target/release/rustscan /usr/local/bin/
echo
echo
echo "Instalacion finalizada !!!."
echo
echo
