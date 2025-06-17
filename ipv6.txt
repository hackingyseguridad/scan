# IPv4 vs IPv6

80.58.0.97/32  255.255.255.255
80.58.32.33/32 255.255.255.255
2a02:9000:0000:0000:0000:0000:0000:aaaa  /64  
2a02:9000:0000:0000:0000:0000:0000:bbbb  /64  la ultima IP de este prefix seria: 2a02:9000:0000:0000:ffff:ffff:ffff:ffff , cuenta en Hexadecimal

Una direccion IPv4 tiene una logitud de 32 bit  192.255.255.255

Una dirección IPv6 consta de 4 octetos de 8 bit, con una logngitud total de 128 bit. utilizan numeración hexadecimal. Las posibilidades de combinaciones y por tanto direcciones seria "casi infinita"!

2a02:0000:0000:0000:0000:0000:0000:0001 y logintud del prefijo p. ej /64

# Reglas para evitar temer que escribir todos los digitos, podemos omitir los 0 iniciales en cada octeto., por lo que quedaria: 

2a02:::::::1
2a02:9000::::::aaaa 

# Formato dirección IPv6: 

2a02:9140:3c00:5300:d14d:2dac:f742:387c/64

Prefix /64: 2a02:9140:3c00:5300 dentro del prefix el ultimo octeto seria el ID Subnet es 5300 /16, e interface: d14d:2dac:f742:387c direcciones disponibles!

Para un prefix /64 el numero total de combinaciones y por tanto de direcciones posibles seria  18.446.744.073.709.551.616 

Carlculadora IPv6 https://www.vultr.com/es/resources/subnet-calculator-ipv6/ 
IP reservadas por AS3352 Telefonica Esp https://bgp.he.net/AS3352#_prefixes6
whois -h whois.radb.net -i origin 3352 | awk '/^route:/ {print $2;}' | sort | uniq
whois -h whois.radb.net -i origin 3352 | awk '/^route6:/ {print $2;}' | sort | uniq

# Tipos de IPv6, segun la IANA, que es la entidad que supervisa la asignación global de direcciones IP: Unicast, Multicast y Anycast

1º.- Unicas o especiales!  identifica un único interfaz de red

Global Unicast: Que tiene prefijo 2a02:9140:3c00:5300:d14d:2dac:f742:387c/64

Link-local: No son enrutables. Suelen empezar por FE80::/10. Al arracan un sistema con SLAAC. calcula por la MAC y autoasigna Por ej.: fe80::a277:5444:5879:9de4

loppback: :1/128

Embebida IPv4: ::ffff:0.0.0.0

2º.- Multicast: Son para envio de paquetes a todos los host, routers de la red Empiezan por FF01::01,  FF01::02, FF01::03, FF01::04, FF01::05

3º.- Anycast: unidifusión que se puede asignar a varios dispositivos.  

4º.- Reservadas o de Broadcast, no son enrutables: 0:0:0:0:0:0:0:0:0/8

Un mismo interface de red puede tener asignadas distintos tipos de direcciones IPv6, p.ej:

eth1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.1.76  netmask 255.255.255.0  broadcast 192.168.1.255
        inet6 fde8:39:a130:0:9fbb:ff3b:6332:de2b  prefixlen 64  scopeid 0x0<global>
        inet6 2a02:9140:3c00:5300:d14d:2dac:f742:387c  prefixlen 64  scopeid 0x0<global>
        inet6 fe80::a277:5444:5879:9de4  prefixlen 64  scopeid 0x20<link>
        ether f0:4d:a2:f7:55:86  txqueuelen 1000  (Ethernet)
        RX packets 19526  bytes 1948492 (1.8 MiB)
        RX errors 0  dropped 1119  overruns 0  frame 0
        TX packets 15068  bytes 1795417 (1.7 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

192.168.1.76 es la IPv4 LAN asinada por el DCHP del router HGU de Telefonica

2a02:9140:3c00:5300:d14d:2dac:f742:387c , es la IPv6 publica enrutable asinada a este interface por la infraestructura de red, servicio DualStack

fde8:39:a130:0:9fbb:ff3b:6332:de2b , es dirección IPv6 de enlace local (Link-local),
calculada automaticamente a partir del valor de la dirección MAC de la tarjeta de red 

f0:4d:a2:f7:55:86 MAC address de la interface Ethernet eth1, de este PC

Referncias:
https://es.wikipedia.org/wiki/Dirección_de_Enlace-Local
https://github.com/hackingyseguridad/scan/blob/master/mac2linklocal.sh

