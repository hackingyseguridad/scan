


echo
echo "Ocultar la versión del SO, fingerprint, Sistema Operativo Linux utilizado con el tamaño del TTL"
echo 
echo "Modifica el TTL a 129, por defecto Kali Linux es 64"
sudo sysctl -w net.ipv4.ip_default_ttl=129
echo "."
echo ".."
echo "..."
echo "Ok!"
echo "Ver el fichero /proc/sys/net/ipv4/ip_default_ttl "
cat /proc/sys/net/ipv4/ip_default_ttl
