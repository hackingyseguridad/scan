#!/bin/bash
# Version Beta (c) Antonio Taboada 2017
echo "###############################################################"
echo "# Script para escaneos de puertos con Nmap: (http://nmap.org) #"
echo "# En modo consola dar permisos de ejecucion: chmod +x scan.sh #"
echo "# Ejecutar en consola con privilegios de SuperUser: ./scan.sh #"
echo "# Incluir en la misma carpeta con rangos IP a scanear: ip.txt #"
echo "# Al finalizar se generara en la misma carpeta: resultado.txt #"
echo "###############################################################"
# Top20 puetos TCP para escaneo fast:21,22,23,25,53,80,139,389,443,554,445,631,966,1023,1723,1080,5900,8080,8443,10000
# TopTelnet puertos: 23,2323,85,70,5001,8000,8023,8083,10000,10001
# TopWEB puetos TCP para escano: 80,443,6443,8080,8834,10000,20000,2222,7000,9009,7443,2087,2096,8443,4100,2082,2083,2086,9000,2052,9001,9002,7000,7001,8188,8089,8189,8082,8084,8085,8010,9000,2078,2080,2079,2053,2095,4000,5200,8888,9443,5000,631,8000,8087,84,85,86,88,10125,9003,7071,8383,7547,3434,10443,8089,3004,81,4567,7081,82,444,1935,3000,9998,4431,4443,83,90,8001,8099,80,300,443,591,593,832,981,1010,1311,2400,3128,3333,4243,4711,4612,4993,5000,5104,5108,6543,7396,7474,8014,8834,8042,8069,8081,8888,8090,8091,8118,8123,8172,8222,8243,8280,8281,8333,8500,8834,8880,8983,9043,9060,9080,9091,9200,9800,9981,12443,16000,18091,18092,20720,28017
# TopSSH puertos: 22,23,26,80,221,222,443,1022,1024,2020,2022,2211,2222,2223,2233,2332,3001,4022,4118,4433,4444,5000,5001,5222,5555,6666,7102,7777,8022,8080,9000,9022,10000,10001,10022,20000,22022,22222,30022,50000
echo
echo "u) Ultra rapido: puertos udp/tcp"
echo "0) Rapido: 100 puertos udp/tcp como proceso Linux"
echo "1) Rapido: 100 puertos udp/tcp"
echo "2) Normal: 1000 puertos udp/tcp"
echo "3) Completo: 65535 puertos udp/tcp"
echo "f) Saltar firewall"
echo "4) NTP"		
echo "5) DNS"
echo "6) IPv6"
echo "7) SNMP"
echo "8) Telnet"
echo "9) SSH"
echo "w) Netbios, SMB"
echo "h) http"
echo "c) Cabeceras"
echo "m) smtp"
echo "n) ssdp"
echo "p) Solo Ping"
echo "d) Descubrimiento host"
echo "i) Resolucion inversa rDNS"
echo "e) ftp"
echo "r) RDP"
echo "s) Broadcast"
echo "t) Traceroute"
echo "v) Vulnerabilidades CVE"
echo "b) Reporte en pagina Web"
echo "x) Tor TCP"
echo "q) Salir"
echo "Pulsa opcion del tipo de escaneo UDP/TCP: 0 - 9:"; read x
case $x in
u)
echo ""; masscan -Pn --rate 199 -iL ip.txt -sS --open-only -n -p0-65535 --ports U:0-65535 -oG resultado.txt; tail resultado.txt
;;
0) nmap -iL ip.txt -Pn --open -sUTV --max-retries 1 -F -O -oG resultado.txt&exit ;;
1)
echo ""; nmap -iL ip.txt -Pn --open -sUT --max-retries 1 -F -O -oG resultado.txt; tail resultado.txt
;;
2)
echo ""; nmap -iL ip.txt -Pn --open -sUTCV -O --max-retries 1 -oG resultado.txt; tail resultado.txt
;;
3)
echo ""; nmap -iL ip.txt -Pn --open -sUTCV -O --max-retries 1 -p 0-65535 -oG resultado.txt; tail resultado.txt
;;
f)
echo ""; nmap -iL ip.txt -Pn -g0 --open -sUTSCV -O --max-retries 1 -p 0-65535 --defeat-rst-ratelimit --script firewall-bypass -oG resultado.txt; tail resultado.txt
;;
4)
echo ""; nmap -iL ip.txt -Pn --open -sUTCV -O --max-retries 1 -p123 --script ntp-monlist -oG resultado.txt; tail resultado.txt
;;
5)
echo ""; nmap -iL ip.txt -Pn --open -sUTCV -O --max-retries 1 -p53 --script dns-recursion -oG resultado.txt; tail resultado.txt
;;
6)
echo ""; nmap -iL ip.txt -6 -Pn --open -sUTCV -O --max-retries 1 -oG resultado.txt; tail resultado.txt
;;
7)
echo ""; nmap -iL ip.txt -Pn --open -sUTCV -O --max-retries 1 -p161 --script snmp-info -oG resultado.txt; tail resultado.txt
;;
8)
echo ""; nmap -iL ip.txt -Pn --open -sCV -O -p23 -oG resultado.txt; tail resultado.txt
;;
9)
echo ""; nmap -iL ip.txt -Pn --open -sTCV -O -p22,222,1022,2020,2022,2211,2222,2223,2233,5222,7102,8022,9022,10022,20000,22022,22222,30022 -oG resultado.txt; tail resultado.txt
;;
w)
echo ""; nmap -iL ip.txt -Pn --open -sUTCV -O --max-retries 1 -p137,138,139,445 --script smb-protocols -oN resultado.txt; tail resultado.txt
;;
h)
echo ""; nmap -iL ip.txt -Pn -p80,443,6443,8080,8834,10000,20000,2222,7000,9009,7443,2087,2096,8443,4100,2082,2083,2086,9000,2052,9001,9002,7000,7001,8188,8089,8189,8082,8084,8085,8010,9000,2078,2080,2079,2053,2095,4000,5200,8888,9443,5000,631,8000,8087,84,85,86,88,10125,9003,7071,8383,7547,3434,10443,8089,3004,81,4567,7081,82,444,1935,3000,9998,4431,4443,83,90,8001,8099,80,300,443,591,593,832,981,1010,1311,2400,3128,3333,4243,4711,4612,4993,5000,5104,5108,6443,6543,7396,7443,7474,8014,8834,8042,8069,8081,8888,8090,8091,8118,8123,8172,8222,8243,8280,8281,8333,8500,8834,8880,8983,9043,9060,9080,9091,9200,9800,9981,12443,16000,18091,18092,20720,28017 --script http-enum --open -sCV -O -oG resultado.txt; tail resultado.txt
;;
c)
echo ""; nmap -iL ip.txt -Pn --open -sVCUT --max-retries 1 -F -O --script=http-security-headers -oG resultado.txt; tail resultado.txt
;;
m)
echo ""; nmap -iL ip.txt -Pn -p25 --script=smtp* -sCV -O --open -oG resultado.txt; tail resultado.txt
;;
n)
echo ""; nmap -iL ip.txt -Pn --open -sUCV -p1900 --max-retries 1 -oG resultado.txt; tail resultado.txt
;;
p)
echo ""; nmap -iL ip.txt -sn -oG resultado.txt; tail resultado.txt
;;
d)
echo ""; nmap -iL ip.txt -PE -oG resultado.txt; tail resultado.txt
;;
i)
echo ""; nmap -iL ip.txt -sL -R --dns-servers 194.179.1.100 -oG resultado.txt; tail resultado.txt
;;
e)
echo ""; nmap -iL ip.txt -Pn --open -sCV -O -p21 -oG resultado.txt; tail resultado.txt
;;
r)
echo ""; nmap -iL ip.txt -Pn --open -sCV -O -p3389 -oG resultado.txt; tail resultado.txt
;;
s)
echo ""; nmap -iL ip.txt -Pn --script=broadcast* --script-args=newtargets -sCV -O --open -oG resultado.txt; tail resultado.txt
;;
t)
echo ""; nmap -iL ip.txt -Pn --open --traceroute  --script=traceroute-geolocation -oN resultado.txt
;;
v)
echo ""; nmap -iL ip.txt -Pn --open -sVUT --max-retries 1 -F -O --script=vulners.nse -oS resultado.txt; tail resultado.txt
;;
b)
echo ""; nmap -iL ip.txt -Pn --open -sVUT --max-retries 1 -F -O --script=vulners.nse -oX resultado.xml; xsltproc resultado.xml -o index.html; python -m SimpleHTTPServer 80
;;
x)
echo ""; OIFS=$IFS; IFS=$'\n'; service tor start; proxychains nmap -iL ip.txt --open -sVC -O -oG resultado.txt
;;
*)
echo "Opcion no valida!"
;;
esac
