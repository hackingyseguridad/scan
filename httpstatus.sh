# consulta HTTP status de listado de fqdn en fichero dominios.txt
# crawler
#!/bin/bash
for n in `cat dominios.txt`; do echo $n; curl $n -I --silent|grep HTTP; done
