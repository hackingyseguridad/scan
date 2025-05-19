















grep -E -A10 "Nmap scan report for|Running \(JUST GUESSING\):|Aggressive OS guesses:" resultado.txt | awk '
  /Nmap scan report for/ { ip = $5 }
  /Running \(JUST GUESSING\):/ { print ip, $0; next }
  /Aggressive OS guesses:/ && !/Running/ { print ip, $0 }
' | sed 's/Nmap scan report for //; s/Running (JUST GUESSING): //; s/Aggressive OS guesses: //'
