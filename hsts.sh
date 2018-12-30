# consulta cabecera HSTS activa en listado de fqdn en fichero dominios.txt
# crawler
#!/bin/bash
for n in `cat dominios.txt`; do echo $n; curl https://$n -s -D- |grep Strict; done
