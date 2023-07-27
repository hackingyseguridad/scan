nmap $1 $2 -sS -sV -n -Pn -T5 -p80 -oG - | grep 'open'
