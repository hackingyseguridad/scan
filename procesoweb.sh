#!/bin/bash
# Ejecuta escaneo de puertos y genera reporte html
sudo apt-get install nmap
sudo nmap -il todas.txt -Pn -sVC -O -T5- -p 21,22,23,25,53,80,139,222,389,443,445,554,631,966,1023,1723,1080,2022,2222,3389,5900,7443,8080,8443,8888,10000,22222 --open --script=ssl* --script=vuln* -oX index.xml
sudo apt-get install xsltproc
sudo xsltproc index.xml -o /var/www/html/index.html
