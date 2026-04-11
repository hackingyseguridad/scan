#!/bin/sh
# traceroute monitor, muestra si hay cambios con ruta anteriores

DEST="hackingyseguridad.com"
PORT=443
TMP_CUR="/tmp/trace_cur.$$"
TMP_PREV="/tmp/trace_prev.$$"

# Colores básicos (compatibles)
RED="$(printf '\033[31m')"
GREEN="$(printf '\033[32m')"
YELLOW="$(printf '\033[33m')"
RESET="$(printf '\033[0m')"

print_header() {
    clear
    echo "Traceroute monitor TCP $DEST:$PORT"
    echo "--------------------------------------------------------------------------"
    printf "┌─────┬─────────────────┬────────────┬──────────────────────────────────────────────┬─────────┐\n"
    printf "│ Hop │ IP              │ ASN        │ AS Nombre                                    │ Pais    │\n"
    printf "├─────┼─────────────────┼────────────┼──────────────────────────────────────────────┼─────────┤\n"
}

get_asn_info() {
    IP="$1"

    # Consulta simple a whois (compatible antiguo)
    WHOIS=$(whois "$IP" 2>/dev/null)

    ASN=$(echo "$WHOIS" | awk '/origin/ {print $2; exit}')
    [ -z "$ASN" ] && ASN=$(echo "$WHOIS" | awk '/OriginAS/ {print $2; exit}')

    ASNAME=$(echo "$WHOIS" | awk -F: '/descr/ {print $2; exit}' | sed 's/^ *//')
    COUNTRY=$(echo "$WHOIS" | awk -F: '/country/ {print $2; exit}' | sed 's/^ *//')

    [ -z "$ASN" ] && ASN="?"
    [ -z "$ASNAME" ] && ASNAME="?"
    [ -z "$COUNTRY" ] && COUNTRY="?"

    echo "$ASN|$ASNAME|$COUNTRY"
}

run_trace() {
    traceroute -T -p $PORT -n "$DEST" 2>/dev/null | awk '
    /^[ 0-9]/ {
        hop=$1
        ip=$2
        if (ip ~ /^[0-9.]+$/) {
            print hop "|" ip
        }
    }' > "$TMP_CUR"
}

compare_and_print() {

    print_header

    while IFS="|" read HOP IP; do

        INFO=$(get_asn_info "$IP")
        ASN=$(echo "$INFO" | cut -d'|' -f1)
        ASNAME=$(echo "$INFO" | cut -d'|' -f2)
        COUNTRY=$(echo "$INFO" | cut -d'|' -f3)

        COLOR=""

        if [ -f "$TMP_PREV" ]; then
            PREV_LINE=$(grep "^$HOP|" "$TMP_PREV")
            PREV_IP=$(echo "$PREV_LINE" | cut -d'|' -f2)

            if [ "$PREV_IP" != "$IP" ]; then
                COLOR="$RED"
            fi
        fi

        printf "│ %-3s │ %s%-15s%s │ %-10s │ %-44s │ %-7s │\n" \
            "$HOP" "$COLOR" "$IP" "$RESET" "$ASN" "$ASNAME" "$COUNTRY"

    done < "$TMP_CUR"

    printf "└─────┴─────────────────┴────────────┴──────────────────────────────────────────────┴─────────┘\n"
}

# Bucle infinito
while true; do

    run_trace
    compare_and_print

    cp "$TMP_CUR" "$TMP_PREV"

    echo "(r) http://www.hackingyseguridad.com/"
    echo "prueba siguiente traza... en 10 segundos! "
    sleep 11

done
