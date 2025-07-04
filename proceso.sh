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
    (c) 2025             ||   (\o/)   ||
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
do nmap $1 -iL ip.txt -PE -sTV --open -n --defeat-rst-ratelimit --randomize-hosts --max-retries 2 -O --osscan-guess $0 --min-rate 100 --script=default,banner,vuln,vulners --script-args mincvss=8  -oN $contador -oX index.xml
# do nmap $1 -iL ip.txt -Pn -sV -O --open --defeat-rst-ratelimit --script=default,banner,vuln,vulners --script-args mincvss=8 -oX index.xml -oN $contador
sudo xsltproc index.xml -o /var/www/html/reports/informe.htm
echo
echo "Generaldo fichero con resultado.: "$contador
echo
cp $contador resultado.txt
rm $contador

# file="resultado.txt"
#if grep -q "CVE" "$file"; then
# echo "Vulnerabilidades CVE" | mail -s "Alerta: CVE encontrado" admin@localhost
# fi

echo
echo "Presiona [CTRL+C] para parar..."
sleep 3
echo
done

