#!/bin/bash
nmap -Pn -sV --script freevulnsearch.nse --script-args notls=yes $1 $2 $3 $4 $5
