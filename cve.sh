#!/bin/sh
# https://github.com/scipag/vulscan
# https://github.com/vulnersCom/nmap-vulners
nmap -iL ip.txt -Pn --open -sVUT --max-retries 1 -O  --defeat-rst-ratelimit --script=vulners.nse 
