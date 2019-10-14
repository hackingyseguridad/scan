#!/bin/bash
nmap -Pn -sV --script=vulners.nse $1 $2 $3 $4 $5
