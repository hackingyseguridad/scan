#!/bin/sh
nmap -iL ip.txt -Pn --open -sUT --max-retries 1 -F -O --script=/scan/nmap-vulners/vulners.nse 
