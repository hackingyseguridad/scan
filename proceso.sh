#!/bin/bash
# Para ejcutar como proceso: nohup ./proceso.sh &
# Ejecuta escaneo de puertos y genera reporte informe.htm
# ps -ALL |grep nmap
# Uso.: sh proceso.sh IP &
echo
cat << "INFO"

-=[ Proceso escaneo TCP a web ]=- @hackgyseguridad
                          _____________
                         |.-----------.|
 hackingyseguridad.com   ||     _     ||
    (c) 2021             ||   (\o/)   ||
                         ||    /_\    ||
 Escaneo de puertos,     ||___________||
 con nmap que convierte,  `-)-------(-'
 el resultado XML a web ,  [=== -- o ]--.
 en formato html         __'---------'__ \
                        [::::::::::: :::] )
http://goo.gl/ID8XBX     `""'"""""'""""`/T\
                                        \_/
INFO
echo
echo

mkdir /var/www/html/reports
sudo apt-get install nmap
sudo apt-get install xsltproc

while :
contador=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
do sudo nmap $1 -iL ip.txt -Pn -sTVC -O --open -p 21,22,23,25,53,123,139,161,222,389,443,445,500,554,631,966,1023,1723,1080,2022,2222,3389,5222,5900,7443,8080,8443,8888,10000,22222 --script=vuln* -oX index.xml -oG $contador
sudo xsltproc index.xml -o /var/www/html/reports/informe.htm
echo
echo "Generaldo fichero con resultado.: "$contador
echo
echo "Presiona [CTRL+C] para parar..."
sleep 3
echo
done
