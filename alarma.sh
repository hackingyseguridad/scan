#!/bin/bash

# Script de monitoreo de conexio▒n con alarma por sonido
# Monitorea ping a 8.8.8.8 y emite beep si falla la conexio▒n

IP="8.8.8.8"
INTERVALO=2  # segundos entre pings
CONTADOR_FALLOS=0
FALLOS_PARA_ALARMA=1


echo
echo "Monitoreo de conexion a $IP"
echo
echo "http://www.hackingyseguridad.com/"
echo
echo "Presiona Ctrl+C para detener"

while true; do
    if ping -c 1 $IP > /dev/null 2>&1; then
        # Ping exitoso
        CONTADOR_FALLOS=0
        printf "\r✓ Conexion OK - $(date '+%H:%M:%S')      "
    else
        # Ping fallido
        CONTADOR_FALLOS=$((CONTADOR_FALLOS + 1))
        printf "\r✗ Falla de conexion - $(date '+%H:%M:%S') - Fallo #$CONTADOR_FALLOS"

        if [ $CONTADOR_FALLOS -ge $FALLOS_PARA_ALARMA ]; then
            # Emitir solo un beep por fallo confirmado y continuar monitoreo
            echo -e '\a'  # Carácter de beep
            printf " - ALARMA SONORA"
        fi
    fi

    sleep $INTERVALO
done
