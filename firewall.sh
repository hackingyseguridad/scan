#!/bin/bash
# (c) hacking y seguridad .com 2022
# escaneo para detectar puertos filtrados por ACL o Firewall
# https://nmap.org/book/determining-firewall-rules.html
# Los resultados con estado unfiltered http son puertos filtrados. con nmap envia ACK  y se obtiene un RST
# 
#
nmap -iL http2.txt -Pn -g0 --open -sACV  -T4 -f -O --max-retries 1 --defeat-rst-ratelimit --script firewall-bypass  -p 80,10443,5411,443,4433,8443,4443,444,9443,7443,1723,6443,8009,10000,55443,9000,8081,8880,8889,9001 -oG resultado_firewall.txt
cat resultado_firewall.txt | grep unfiltered
