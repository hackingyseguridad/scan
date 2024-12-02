# Si encuentra vulnerabilidades en el restuldado.txt, envia por email lo encontrado!
# hackingyseguridad.com

#!/bin/bash

# Archivo a buscar
file="resultado.txt"

# Buscar la palabra "CVE" y guardar la línea en una variable
line=$(grep "CVE" "$file")

# Si se encuentra la línea, enviar un correo electrónico
if [ -n "$line" ]; then
    echo "$line" | mail -s "Vulnerabilidad CVE" hackingyseguridad@hackingyseguridad.com
fi
