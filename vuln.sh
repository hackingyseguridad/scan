#!/bin/bash
nmap -Pn $1 $2 $3 $4 $5 -sS -sV --script=default,vuln -p- -T5 
