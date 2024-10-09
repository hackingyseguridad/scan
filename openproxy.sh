echo "hackingyseguridad.com 2024"
echo "chequea IP con proxy http abierto!"
echo
echo "sh openproxy.sh"
echo "lee fichero ip.txt"
echo
for n in `cat ip.txt`

do
        if timeout 1 curl -x http://$n:8081  -k -s "http://hackingyseguridad.com/security.txt" \
-H 'Pragma: no-cache' \
-H 'Cache-Control: no-cache' \
-H 'Upgrade-Insecure-Requests: 1' \
-H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.120 Safari/537.36' \
-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3' \
-H 'Accept-Encoding: gzip, deflate, br' \
-H 'Accept-Language: es-ES,es;q=0.9,en;q=0.8' \
        then echo $n && echo
        fi
done
