#!/bin/sh
# Script para encontrar IPs coincidentes entre ip.txt e ip2.txt
# Compatible con Bash 1.0.x y shells antiguos

# Verificar que ambos archivos existen
if [ ! -f ip.txt ]; then
    echo "Error: No se encuentra el archivo ip.txt"
    exit 1
fi

if [ ! -f ip2.txt ]; then
    echo "Error: No se encuentra el archivo ip2.txt"
    exit 1
fi

# Mostrar mensaje de inicio
echo "Buscando IPs coincidentes entre ip.txt e ip2.txt..."
echo "----------------------------------------"

# Variable para contar coincidencias
coincidencias=0

# Usar un archivo temporal para mejor compatibilidad
temp_file=/tmp/ip_coincidencias_$$.tmp

# Crear un archivo con las IPs del segundo archivo para búsqueda rápida
# usando solo comandos básicos compatibles con shells antiguos
cat ip2.txt > $temp_file

# Leer ip.txt línea por línea
while read ip; do
    # Saltar líneas vacías
    if [ -z "$ip" ]; then
        continue
    fi
    
    # Buscar la IP en el archivo temporal
    # Usar grep básico sin opciones modernas
    if grep -x "$ip" $temp_file > /dev/null 2>&1; then
        echo "$ip"
        coincidencias=`expr $coincidencias + 1`
    fi
done < ip.txt

# Limpiar archivo temporal
rm -f $temp_file

echo "----------------------------------------"
echo "Total de IPs coincidentes: $coincidencias"
