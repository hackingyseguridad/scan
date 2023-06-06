#!/bin/bash
# Script para deputar el fichero resultado.txt, extraer las IP IPv4  y eliminar duplicados
# Script para IPv4
# Lee del fichero resultado.txt la lista de IP, entrega el resultado en el fichero resultado2.txt
# Uso: sh depura.sh
# (C) hackingyseguridad.com 2023
echo
echo ".."
# Limpia de caracteres especiales el fichero de entrada ip.txt con direcciones IP IPv4
grep -Eo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" resultado.txt > resultado1.txt
echo "..."
# Elimina IP duplicadas y genera resultado3.txt
awk '!visited[$0]++' "resultado1.txt" > resultado2.txt
echo "... Ok"
