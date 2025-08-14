#!/bin/sh
# https://github.com/nmap/nmap/tree/master/scripts
# https://github.com/scipag/vulscan
# https://github.com/vulnersCom/nmap-vulners
# https://github.com/scmanjarrez/CVEScannerV2/
# https://github.com/scmanjarrez/CVEScannerV2DB/
# https://github.com/roomkangali/DursVulnNSE

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

echo "actualizando CVEScannerV2"
rm CVEScannerV2 -R
git clone https://github.com/scmanjarrez/CVEScannerV2
ln -s `pwd`/CVEScannerV2 /usr/share/nmap/scripts/CVEScannerV2

echo "actualizando dursvuln"
git clone https://github.com/roomkangali/DursVulnNSE
ln -s `pwd`/DursVulnNSE /usr/share/nmap/scripts/DursVulnNSE

echo
sudo nmap --script-updatedb

echo
nmap $1 -Pn --open  $2 $3 $4 $5 -sV --script=default,vuln -p- -T5
echo "###"
nmap $1 -Pn --open  $2 $3 $4 $5 -sV -F -O  --defeat-rst-ratelimit --script=nmap-vulners/vulners.nse --script-args mincvss=7
echo "###"
nmap $1 -Pn --open  $2 $3 $4 $5 -sV -F -O  --defeat-rst-ratelimit --script=vulscan/vulscan.nse --script-args vulscandb=cve.csv
echo "###"
nmap $1 -sV --open  $2 $3 $4 $5 -sV -F -O  --defeat-rst-ratelimit  --script=CVEScannerV2/cvescannerv2.nse
echo "###"
nmap $1 -sV --open  $2 $3 $4 $5 -sV -F -O  --defeat-rst-ratelimit --script =dursvuln.nse


