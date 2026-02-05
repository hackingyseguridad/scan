#!/bin/bash
#
# IIS Scaner de vulnerabilidades rápido para rangos de red
# Uso: ./iis.sh <rango CIDR>
# Ejemplo: ./iis.sh 192.168.0.0/24
# nmap $1 $2 $3 -Pn -p 80,443,8443 --open -sV --script http-server-header,http-headers,http-title  -oN resultado.txt

nmap $1 $2 $3 -Pn -p 80,443,8443,8080,8172,10443 --open -sV \
--script "http-server-header,http-headers,http-title" \
--script-args "http-headers.useragent='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'" \
-oN resultado.txt \
echo
cat resultado.txt | grep -Ei "Nmap scan report for|IIS|ASP.NET|X-AspNet|Microsoft-IIS|VIEWSTATE|AspNet|deploy|msdeploy|Microsoft|cityworks|X-Powered-By|X-AspNet-Version"
echo

