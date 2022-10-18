# escaneo para detectar puertos filtrados por ACL o Firewall
# https://nmap.org/book/determining-firewall-rules.html
# Los resultados con estado unfiltered http son puertos filtrados. Se envia ACK  y se obtiene un RST
nmap -sA -T4 -iL ip.txt -p 80
