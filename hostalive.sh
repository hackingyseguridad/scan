#!/bin/bash
for n in `cat ip.txt`; do if ping $n -c 1 -W 1 >/dev/null; then
        echo $n "Up"
else
        echo $n "Down"
fi
done;
