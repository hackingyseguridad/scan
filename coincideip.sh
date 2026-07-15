#!/bin/sh
# Script para encontrar IPs coincidentes entre ip.txt e ip2.txt
# Compatible con Bash 1.0.x y shells antiguos + progreso

# Verificar que ambos archivos existen
if [ ! -f ip.txt ]; then
    echo "Error: No se encuentra el archivo ip.txt"
    exit 1
fi

if [ ! -f ip2.txt ]; then
    echo "Error: No se encuentra el archivo ip2.txt"
    exit 1
fi

# Contar total de líneas para el progreso
total=$(wc -l < ip.txt)
if [ "$total" -eq 0 ]; then
    echo "El archivo ip.txt está vacío."
    exit 1
fi

# Mostrar mensaje de inicio
echo "Buscando IPs coincidentes entre ip.txt e ip2.txt..."
echo "Procesando $total líneas..."
echo "----------------------------------------"

# Variable para contar coincidencias y progreso
coincidencias=0
procesadas=0

# Archivo temporal para búsqueda rápida
temp_file=/tmp/ip_coincidencias_$$.tmp
cat ip2.txt > "$temp_file"

# Leer ip.txt línea por línea con progreso
while read ip; do
    procesadas=$((procesadas + 1))
    
    # Mostrar progreso (sobrescribe la misma línea)
    porcentaje=$((procesadas * 100 / total))
    printf "\rProcesando: %3d%% (%d/%d)" "$porcentaje" "$procesadas" "$total"
    
    # Saltar líneas vacías
    if [ -z "$ip" ]; then
        continue
    fi
    
    # Buscar coincidencia
    if grep -x "$ip" "$temp_file" > /dev/null 2>&1; then
        echo ""  # Nueva línea para mostrar la IP coincidente
        echo "$ip"
        coincidencias=$((coincidencias + 1))
    fi
done < ip.txt

# Limpiar
rm -f "$temp_file"

# Finalizar con línea nueva y resumen
printf "\n----------------------------------------\n"
echo "Total de IPs coincidentes: $coincidencias"
