# Escanea Node.JS
nmap -Pn $1 $2 $3 $4 -p 3000,3001,5000,8080,8081,8000,1337,4200  -sV --script=http-headers,http-devframework -T4 
