# escanea Proxyes abiertos
#
# https://proxy5.net/free-proxy
#
nmap -Pn $1 $2 $3 --script=http-open-proxy,socks-open-proxy -p 1080,8080,8000,3128,8081,8888 -sV --open

