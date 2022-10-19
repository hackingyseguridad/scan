# escaneo para detectar puertos filtrados por ACL o Firewall web
# https://nmap.org/book/determining-firewall-rules.html
# Los resultados con estado filtered/unfiltered http son puertos filtrados. Se envia ACK  y se obtiene un RST
nmap -sA -T4 -iL ip.txt -p 80,10443,5411,443,4433,8443,4443,444,9443,7443,1723,6443,8009,10000,55443,9000,8081,8880,8889,9001
