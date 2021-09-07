nmap -n -Pn -vv -A $1 $2 --min-parallelism=50 --max-parallelism=150 -PN -T2 -oA x.x.x.x
