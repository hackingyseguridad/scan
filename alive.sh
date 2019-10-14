for i in {1..254}; do ip=192.168.1.$i; if ping $ip -c 1 -W 1 > /dev/null; then echo $ip " => Up "; fi; done
