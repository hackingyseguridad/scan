# Si encuentra vulnerabilidades en el restuldado.txt, envia por email lo encontrado!
# hackingyseguridad.com 2025

#!/bin/sh

nmap -iL todas -F -PE -sTV --open -O -n --randomize-hosts --max-retries 2 -O --osscan-guess $0 --min-rate 1000 -oG resultado.txt -oX index.xml

# Archivo resultado.txt
file="resultado.txt"

# Comprobar si el fichero contiene vulnerabilidades CVE
if grep -q "CVE" "$file"; then
    # Enviar correo electrónico si se encuentra la palabra CVE
    echo "Vulnerabilidades CVE" | mail -s "Alerta: CVE encontrado" admin@localhost
fi

