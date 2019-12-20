for i in {1..254}; do ip=192.168.1.$i; if telnet $ip 80 &sleep 3; then echo; fi; done
