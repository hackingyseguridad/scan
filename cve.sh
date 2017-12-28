#!/bin/sh
nmap -iL ip.txt -Pn --open -sVUT --max-retries 1 -O  --defeat-rst-ratelimit --script=vulners.nse 
