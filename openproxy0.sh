echo "hackingyseguridad.com 2024"
echo "chequea IP con proxy http abierto!"
echo "Puertos TCP habituales Proxy; 1080;3128,8000,8080,8081,8888"
echo "timeout 5 curl -x socks5://IP_proxy:8888 hackingyseguridad.com"
echo
echo
for n in `cat proxy.txt`
do 
timeout 3 curl -x http://$n:1080 -k --silent "http://ipecho.net/plain" 
timeout 3 curl -x https://$n:1080 -k --silent "http://ipecho.net/plain" 
timeout 3 curl -x socks4://$n:1080 -k --silent "http://ipecho.net/plain" 
timeout 3 curl -x socks5://$n:1080 -k --silent "http://ipecho.net/plain" 
done
