echo
echo "(C) hackingyseguridad.com 2021"
echo
echo "Extrae el dominio, del certificado digital, de la IP "
echo "Uso:"
echo "sh ip2dominio.sh < IP-rango >"

nmap $1 $2 -p 443,8443 --script=ssl-cert  | grep "DNS:"
