#!/bin/sh
# https://github.com/scipag/vulscan
# https://github.com/vulnersCom/nmap-vulners
nmap -iL ip.txt -Pn --open -sVUT -F -O --max-retries 1 -O  --defeat-rst-ratelimit --script=vulners.nse 
nmap -iL ip.txt -Pn --open -sVUT -F -O --max-retries 1 -O  --defeat-rst-ratelimit --script=vulscan/vulscan.nse
