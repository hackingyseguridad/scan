
#
#  
#
echo
echo "Escanea sistemas operativos"
echo

nmap -Pn $1 $2 $3 --randomize-hosts --max-retries 1 -n --open -sV -O --osscan-guess --script=banner -oG resultado.txt
echo
echo
echo "= RESUMEN ==================================================================="
echo
cat resultado.txt 


