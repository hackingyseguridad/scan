#!/bin/bash
# Para ejcutar como proceso: nohup ./proceso3.sh &
# Ejecuta escaneo de puertos y genera reporte informe3.htm
# ps -ALL |grep nmap
# chmod 777 proceso3.sh
# Uso.: nohup ./proceso3.sh &
echo
cat << "INFO"

-=[ Proceso escaneo TCP a web ]=- @hackgyseguridad
                          _____________
                         |.-----------.|
 hackingyseguridad.com   ||     _     ||
    (c) 2024             ||   (\o/)   ||
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
sudo apt-get install masscan

while :
contador=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
do masscan -Pn --rate 99 -iL todas.txt -sS --open-only -n -p0-65535 -n --randomize-hosts --max-retries 2 -v -oX index.xml -oG $contador
sudo xsltproc index.xml -o /var/www/html/reports/informe3.htm
echo
echo "Generaldo fichero con resultado.: "$contador
echo
echo "Presiona [CTRL+C] para parar..."
sleep 3
echo
done
