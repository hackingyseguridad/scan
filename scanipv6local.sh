# 
echo "Escanea puertos en la direcciones IPv6 link local, de la LAN"
echo 
echo "Uso.: sh scanipv6local.sh"
# 

#!/bin/sh
ping6 -I eth0 -c 2 ff02::1 | grep DUP | awk '{print substr($4, 1, length($4)-1)}' > ip.txt
nmap -6 -Pn sVC -iL ip.txt --open
