echo "hackingyseguridad.com 2024"
echo "chequea IP con proxy http abierto!"
echo "Puertos TCP habituales Proxy; 3128,8000,8080,8081,8888"
echo "timeout 5 curl -x socks5://IP_proxy:8888 hackingyseguridad.com"
echo
echo
for n in `cat proxy.txt`
do 
timeout 3 curl -x http://$n:8081 -k --silent "http://ipecho.net/plain" \
-H 'Pragma: no-cache' \
-H 'Cache-Control: no-cache' \
-H 'Upgrade-Insecure-Requests: 1' \
-H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.120 Safari/537.36' \
-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3' \
-H 'Accept-Encoding: gzip, deflate, br' \
-H 'Accept-Language: es-ES,es;q=0.9,en;q=0.8' \ 
done
            
