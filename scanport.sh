# Escanea las IP o fqdn en fichero ip.txt
# por ejemplo puerto 80
# (c) 2018 hackingyseguridad.com

#!/bin/bash
for n in `cat ip.txt`; do nc -zv $n 80 -w 1; done
