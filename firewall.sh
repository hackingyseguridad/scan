#!/bin/bash
# (c) hacking y seguridad .com 2022
# Escaneo para detectar puertos filtrados por ACL o Firewall
# https://nmap.org/book/determining-firewall-rules.html
# Los resultados con estado "unfiltered" son puertos filtrados; nmap envia ACK  y se obtiene un RST
# Puertos habituales de portales web: -p 80,10443,5411,443,4433,8443,4443,444,9443,7443,1723,6443,8009,10000,55443,9000,8081,8880,8889,9001
# Puerto 0 origen -g 0
nmap -iL ip.txt -Pn --open -sACV  -T4 -f -O --max-retries 1 --defeat-rst-ratelimit --script firewall-bypass -oG resultado_firewall.txt
cat resultado_firewall.txt | grep unfiltered
