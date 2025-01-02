#!/bin/sh
# https://github.com/scipag/vulscan
# https://github.com/vulnersCom/nmap-vulners

rm scipag_vulscan -R
git clone https://github.com/scipag/vulscan scipag_vulscan
ln -s `pwd`/scipag_vulscan /usr/share/nmap/scripts/vulscan

rm nmap-vulners -R
git clone https://github.com/vulnersCom/nmap-vulners
ln -s `pwd`/nmap-vulners /usr/share/nmap/scripts/nmap-vulners

nmap -iL ip.txt -Pn $1 $2 $3 $4 $5 -sS -sV --script=default,vuln -p- -T5
nmap -iL ip.txt -Pn --open -sVUT -F -O  --defeat-rst-ratelimit --script=nmap-vulners/vulners.nse
nmap -iL ip.txt -Pn --open -sVUT -F -O  --defeat-rst-ratelimit --script=vulscan/vulscan.nse --script-args vulscandb=cve.csv

