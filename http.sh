#!/bin/bash
echo
echo "  "
echo "Chequea la respuesta HTTP/2"
chmod 777 htto2.sh
echo "www.hackingyseguridad.com (2023)"
echo "Consulta del fichero ip.txt"
echo "Uso.: ./http2.sh "
for n in `cat ip.txt`
do echo "======>" $n
        fqdn="https://$n:443/"
echo "===>" $fqdn
        if timeout 1 curl --cacert MyRootCA.crt -k -s $fqdn -I --silent --http2-prior-knowledge \
-H 'Pragma: no-cache' \
-H 'Cache-Control: no-cache' \
-H 'Upgrade-Insecure-Requests: 1' \
-H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.120 Safari/537.36' \
-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3' \
-H 'Accept-Encoding: gzip, deflate, br' \
-H 'Accept-Language: es-ES,es;q=0.9,en;q=0.8' \ |grep "HTTP/2"
        then echo $fqdn; echo
        fi
done
