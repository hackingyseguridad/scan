#!/bin/sh
# https://github.com/nmap/nmap/tree/master/scripts
# https://github.com/scipag/vulscan
# https://github.com/vulnersCom/nmap-vulners
# https://github.com/scmanjarrez/CVEScannerV2/
sudo apt-get install lua5.1; sudo apt-get install lua-sql-sqlite3

echo
echo "actualizando vulners"
rm nmap-vulners -R
git clone https://github.com/vulnersCom/nmap-vulners
ln -s `pwd`/nmap-vulners /usr/share/nmap/scripts/nmap-vulners

echo "actualizando vulnscan"
rm scipag_vulscan -R
git clone https://github.com/scipag/vulscan scipag_vulscan
ln -s `pwd`/scipag_vulscan /usr/share/nmap/scripts/vulscan

echo
sudo nmap --script-updatedb

echo
nmap $1 -Pn --open  $2 $3 $4 $5 -sV --script=default,vuln -p- -T5
echo "###"
nmap $1 -Pn --open  $2 $3 $4 $5 -sV -F -O  --defeat-rst-ratelimit --script=nmap-vulners/vulners.nse
echo "###"
nmap $1 -Pn --open  $2 $3 $4 $5 -sV -F -O  --defeat-rst-ratelimit --script=vulscan/vulscan.nse --script-args vulscandb=cve.csv
echo "###"
nmap $1 -sV --open  $2 $3 $4 $5 -sV -F -O  --defeat-rst-ratelimit  --script=CVEScannerV2/cvescannerv2.nse


