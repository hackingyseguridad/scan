# escanea Proxyes abiertos

nmap -Pn $1 $2 $3 --script="http-open-proxy" -p 8123,8080,8000,3128,8081 -sV 

