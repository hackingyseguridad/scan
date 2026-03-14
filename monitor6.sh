#!/bin/bash

# Script de monitoreo de conexion IPv6 con alarma por sonido
# Monitorea ping6 a google.es y emite beep si falla la conexion

HOST="google.es"
INTERVALO=2  # segundos entre pings
CONTADOR_FALLOS=0
FALLOS_PARA_ALARMA=1

echo
echo "Monitoreo de conexion IPv6 a $HOST"
echo
echo "http://www.hackingyseguridad.com/"
echo
echo "Presiona Ctrl+C para detener"
echo

while true; do
    if ping6 -c 1 $HOST > /dev/null 2>&1; then
        # Ping6 exitoso
        CONTADOR_FALLOS=0
        printf "\r✓ Conexion IPv6 OK - $(date '+%H:%M:%S')      "
    else
        # Ping6 fallido
        CONTADOR_FALLOS=$((CONTADOR_FALLOS + 1))
        printf "\r✗ Falla de conexion IPv6 - $(date '+%H:%M:%S') - Fallo #$CONTADOR_FALLOS"

        if [ $CONTADOR_FALLOS -ge $FALLOS_PARA_ALARMA ]; then
            # Emitir solo un beep por fallo confirmado y continuar monitoreo
            echo -e '\a'  # Carácter de beep
            printf " - ALARMA SONORA"
        fi
    fi

    sleep $INTERVALO
done

