#!/bin/bash
nmap -Pn $1 $2 $3 $4 $5 -sV --script=default,vuln,vulners --script-args mincvss=7 -p- --open
