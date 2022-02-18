# consulta vuln en nrich

# https://gitlab.com/shodan-public/nrich

# Instalacion en Linux Debian:
# wget https://gitlab.com/api/v4/projects/33695681/packages/generic/nrich/latest/nrich_latest_amd64.deb
# sudo dpkg -i nrich_latest_amd64.deb

# Ejecucion
# echo IP | nrich - -o json | jq

#!/bin/bash
for n in `cat ip.txt`; do echo $n | nrich - -o json | jq; done
