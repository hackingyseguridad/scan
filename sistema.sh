
#
#  
#
echo 
echo
echo "Escanea sistemas operativos...!"
echo "http://www.hackingyseguridad.com"
echo
nmap -Pn $1 $2 $3 --randomize-hosts --max-retries 1 -n --open -sV -O --osscan-guess --script=banner -oN resultado.txt
echo
echo
echo "= RESUMEN ==================================================================="
echo
grep -E "Nmap scan report for|Running \(JUST GUESSING\):" resultado.txt | awk '/Nmap scan report for/{ip=$NF; next} /Running/{print ip, $0}' 




