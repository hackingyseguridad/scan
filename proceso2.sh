#!/bin/bash
chmod 777 proceso2.sh
# Para ejcutar como proceso: nohup ./proceso.sh &
# Ejecuta escaneo de puertos y genera reporte informe2.htm
# ps -ALL |grep nmap
# Uso.: sh proceso2.sh IP &
echo
cat << "INFO"

-=[ Proceso escaneo UDP a web ]=- @hackgyseguridad
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
do sudo nmap $1 -iL ip.txt -Pn -sUVC -O --open -p 7,9,19,53,67,68,69,113,123,137,138,139,161,162,177,389,443,445,500,514,520,1194,1701,1812,1813,1900,4500,33434 --script=vuln* -oX index2.xml -oG $contador
sudo xsltproc index2.xml -o /var/www/html/reports/informe2.htm
echo
echo "Generaldo fichero con resultado.: "$contador
echo
echo "Presiona [CTRL+C] para parar..."
sleep 3
echo
done
