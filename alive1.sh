echo 
echo "Script con nmap para ver si hay respuesta"
echo "hace un envio masivo de consultas tipo ping ICMP Echo Request" 
echo 
# parametros nmap 
# --min-rate 300  , envia 300 peticiones por segundo. PPs.
# -T4 para dar ago mas de velocidad escaneo, solo con buena conexión a interet
# -T5 modo agresivo, para dar maxima velocidad al escaneo. En LAN o con muy buena conexion internet

nmap -iL ip.txt -PE -T4 --min-rate 300 -p 22 -oN resultado_IPv4.txt




