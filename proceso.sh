#!/bin/bash
# Ejecuta escaneo de puertos y genera reporte html
# ps -ALL |grep nmap
# Uso.: sh proceso.sh IP
echo ******************
echo *** proceso.sh *** 
echo ******************

sudo apt-get install nmap
sudo apt-get install xsltproc

while :

do sudo nmap $1 192.168.1.0/24 -Pn -sVC -O -T5- -p 21,22,23,25,53,80,139,222,389,443,445,554,631,966,1023,1723,1080,2022,2222,3389,5900,7443,8080,8443,8888,10000,22222 --open --script=ssl* --script=vuln* -oX index.xml

sudo xsltproc index.xml -o /var/www/html/index.html
echo
echo "Presiona [CTRL+C] para parar..."
sleep 3
echo
done
