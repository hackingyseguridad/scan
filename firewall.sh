#!/bin/sh
# (R) hackingyseguridad.com 2026
# Escaneo para detectar puertos filtrados por ACL o Firewall
# https://nmap.org/book/determining-firewall-rules.html
# Los resultados con estado "unfiltered" son puertos filtrados; nmap envia ACK  y se obtiene un RST
# Puertos habituales de portales web: -p 80,10443,5411,443,4433,8443,4443,444,9443,7443,1723,6443,8009,10000,55443,9000,8081,8880,8889,9001
# Puertos habituales servidores: -p 21,22,23,25,53,123,139,161,222,389,443,445,500,554,631,966,1023,1720,1723,1080,2022,2222,3389,5222,5900,7443,8080,8443,8888,10000,2222
# Puerto 0 origen -g 0

# Uso: ./firewall.sh <objetivo> [opciones]
echo "Escaneo saltando cortafuegos ..."
nmap $1 $2 $3 $4 -Pn -F --open \
  --max-retries 2 \
  --min-rate 300 \
  --max-rtt-timeout 1500ms \
  --defeat-rst-ratelimit \
  -f \
  --mtu 24 \
  -D RND:10 \
  --data-length 30 \
  -sS \
  -sV \
  -sC \
  -O \
  -T4 \
  -g 0 \
  --script firewall-bypass,http-waf-fingerprint,http-waf-detect \
  -oG resultado_firewall.txt

cat resultado_firewall.txt | grep unfiltered
