<div align="center">

# 🛰️ scan suite

**Colección de scripts en Bash/POSIX sh, PowerShell y NSE para descubrimiento de hosts, escaneo de puertos, detección de firewalls y análisis de vulnerabilidades**

[![Shell](https://img.shields.io/badge/Shell-Bash%20%2F%20POSIX%20sh-89e051)](https://www.gnu.org/software/bash/)
[![Licencia](https://img.shields.io/badge/Licencia-GPL--3.0-blue)](LICENSE)
[![Web](https://img.shields.io/badge/web-hackingyseguridad.com-orange)](http://www.hackingyseguridad.com/)

</div>

---

## ⚠️ Aviso legal y uso responsable

Estas herramientas realizan **escaneos activos de red** (sondeos ICMP, TCP, UDP, detección de SO, fingerprinting de servicios y comprobación de vulnerabilidades). Su uso está destinado **exclusivamente** a:

- Auditorías de seguridad **autorizadas por escrito** por el propietario del sistema/red.
- Entornos de laboratorio, formación o CTF propios.
- Pentesting profesional dentro del alcance (*scope*) pactado con el cliente.

El escaneo de sistemas de terceros sin autorización puede constituir un **delito** (en España, arts. 197 y ss. del Código Penal, entre otros). El autor y los colaboradores de este repositorio **no se hacen responsables** del mal uso de estos scripts.

---

## 📑 Índice

- [Descripción general](#-descripción-general)
- [Requisitos](#-requisitos)
- [Instalación](#-instalación)
- [Ficheros de entrada/salida](#-ficheros-de-entradasalida)
- [Tabla resumen general](#-tabla-resumen-general)
- [Detalle por categoría](#-detalle-por-categoría)
  - [1. Descubrimiento de hosts (alive/ping)](#1-descubrimiento-de-hosts-aliveping)
  - [2. Escaneo de puertos TCP/UDP](#2-escaneo-de-puertos-tcpudp)
  - [3. IPv6](#3-ipv6)
  - [4. Firewalls, IDS y evasión](#4-firewalls-ids-y-evasión)
  - [5. Escaneo web y servicios específicos](#5-escaneo-web-y-servicios-específicos)
  - [6. Detección de proxies abiertos](#6-detección-de-proxies-abiertos)
  - [7. Vulnerabilidades y CVE](#7-vulnerabilidades-y-cve)
  - [8. Información de IP / ASN / geolocalización](#8-información-de-ip--asn--geolocalización)
  - [9. Traceroute y rutas](#9-traceroute-y-rutas)
  - [10. Sistema, monitorización y procesos en local](#10-sistema-monitorización-y-procesos-en-local)
  - [11. Utilidades varias](#11-utilidades-varias)
- [Tablas de puertos de referencia](#-tablas-de-puertos-de-referencia)
- [Documentación adicional](#-documentación-adicional)
- [Licencia](#-licencia)
- [Autor](#-autor)

---

## 📖 Descripción general

`scan` es una suite de **subrutinas independientes** (no un framework monolítico) pensadas para combinarse en flujos de auditoría de red: descubrimiento de hosts vivos → escaneo de puertos → identificación de servicio/SO → detección de vulnerabilidades → informe. Cada script hace **una sola cosa** y puede invocarse suelto desde la línea de comandos o encadenarse con otros mediante los ficheros de texto (`ip.txt`, `resultado.txt`, etc.) que actúan de "pegamento" entre pasos.

La mayoría de scripts están escritos para **Kali Linux**, con dependencia de `nmap`, `masscan`, `whois`, `traceroute`/`mtr` y utilidades estándar de red.

---

## 🧰 Requisitos

| Herramienta | Uso | Instalación (Debian/Kali) |
|---|---|---|
| `nmap` | Motor principal de escaneo de puertos, SO y NSE | `apt-get install nmap` |
| `masscan` | Escaneo masivo de rango de IP a alta velocidad | `apt-get install masscan` |
| `pwncat` | Escaneo de puertos alternativo (`scan`) | `apt-get install pwncat` |
| `whois` | Consultas de rangos BGP/AS (`bgp2ip`, `ip2bgp`) | `apt-get install whois` |
| `traceroute` / `mtr` | Trazado de rutas | `apt-get install traceroute mtr` |
| `ndisc6` | Descubrimiento IPv6 (Neighbor Discovery) | `apt-get install ndisc6` |
| `curl` / `wget` | Peticiones HTTP y descarga de IP pública | preinstalado en Kali |
| `jq` | Parseo JSON (`vuln2.sh`, `cve-db.sh`) | `apt-get install jq` |
| `sqlite3` | Base de datos local de CVE (`cve-db.sh`) | `apt-get install sqlite3` |
| `nrich` | Consulta de vulnerabilidades vía Shodan (`vuln2.sh`) | ver [gitlab.com/shodan-public/nrich](https://gitlab.com/shodan-public/nrich) |
| `asciidoc` (`a2x`) | Conversión de informes txt a PDF (`txt2pdf.sh`) | `apt-get install asciidoc` |
| PowerShell 5.0+ | Solo para `scan.ps1` (Windows) | incluido en Windows / `pwsh` en Linux |

> Algunos scripts requieren permisos de superusuario (`sudo`) para escaneos SYN/OS fingerprinting (`-sS`, `-O`).

---

## 🚀 Instalación

```bash
git clone https://github.com/hackingyseguridad/scan
cd scan
chmod +x instalar.sh
sudo bash instalar.sh
```

`instalar.sh` instala las dependencias (`nmap`, `masscan`, `traceroute`, `whois`, `pwncat`, `libpcap-dev`), descarga los motores NSE de vulnerabilidades (`nmap-vulners`, `scipag/vulscan`, `freevulnsearch`) y copia las utilidades sueltas (`scan`, `bgp2ip`, `ip2bgp`, `ip2pais`, `miip`, `miip2`, `tracebgp`, `scantcp`) a `/sbin/` para poder invocarlas como comandos del sistema.

Instalación rápida de un único script (sin clonar el repo):

```bash
wget https://raw.githubusercontent.com/hackingyseguridad/scan/master/scan.sh && chmod +x scan.sh && ./scan.sh
```

Actualizar solo `scan.sh` a la última versión:

```bash
bash update.sh
```

---

## 📂 Ficheros de entrada/salida

La suite se comunica entre scripts mediante ficheros de texto plano en el directorio de trabajo:

| Fichero | Tipo | Usado por | Contenido esperado |
|---|---|---|---|
| `ip.txt` | Entrada | `scan.sh`, `alive*.sh`, `hostalive.sh`, `http.sh`, `trace.sh`, `rastreador.sh`, `depura.sh`, `coincideip.sh`, `scanport.sh` | Lista de IPs/rangos IPv4, una por línea |
| `ip2.txt` | Entrada | `coincideip.sh` | Segunda lista de IPs a comparar con `ip.txt` |
| `ipv6.txt` | Entrada | `ndisc6.sh`, `rastreador6.sh` | Lista de direcciones IPv6 |
| `todas.txt` | Entrada | `scanpuerto`, `scanpuerto1`, `scanpuertoudp` | Lista de IPs/rangos para escaneo masivo |
| `dominios.txt` | Entrada | `hsts.sh`, `httpstatus.sh` | Lista de FQDN |
| `subdominios.txt` | Entrada | `resolver.sh` | Lista de subdominios a resolver |
| `proxy.txt` | Entrada | `openproxy.sh`, `openproxy0.sh`, `openproxy2.sh` | Lista de IPs de proxies a comprobar |
| `resultado.txt` / `resultado1.txt` / `resultado2.txt` | Salida/intermedio | `scan.sh`, `depura.sh`, `rastreador.sh`, `sistema.sh`, `so.sh`, `firewall2.sh`, `txt2pdf.sh` | Salida `-oG`/`-oN` de nmap y ficheros depurados de IPs |

---

## 📊 Tabla resumen general

| Categoría | Nº scripts | Scripts principales |
|---|---|---|
| [Descubrimiento de hosts](#1-descubrimiento-de-hosts-aliveping) | 9 | `alive.sh`, `hostalive.sh`, `pingscan.sh` |
| [Escaneo de puertos TCP/UDP](#2-escaneo-de-puertos-tcpudp) | 17 | `scan.sh`, `scanpuerto`, `scantcp2` |
| [IPv6](#3-ipv6) | 4 | `scanipv6.sh`, `mac2linklocal.sh` |
| [Firewalls / IDS / evasión](#4-firewalls-ids-y-evasión) | 4 | `firewall.sh`, `tcpwrapped.sh` |
| [Escaneo web y servicios](#5-escaneo-web-y-servicios-específicos) | 7 | `iis.sh`, `nodejs.sh`, `hsts.sh` |
| [Proxies abiertos](#6-detección-de-proxies-abiertos) | 4 | `openproxy.sh`, `proxyopen.sh` |
| [Vulnerabilidades / CVE](#7-vulnerabilidades-y-cve) | 7 | `vuln.sh`, `vscan.sh`, `cve.sh` |
| [Info IP / ASN / GeoIP](#8-información-de-ip--asn--geolocalización) | 8 | `mi-ip.sh`, `ip2bgp`, `bgp2ip` |
| [Traceroute / rutas](#9-traceroute-y-rutas) | 6 | `trace.sh`, `rastreador.sh`, `tracebgp` |
| [Sistema / monitorización local](#10-sistema-monitorización-y-procesos-en-local) | 12 | `local.sh`, `sistema.sh`, `proceso.sh` |
| [Utilidades varias](#11-utilidades-varias) | 6 | `depura.sh`, `txt2pdf.sh`, `instalar.sh` |

---

## 🔎 Detalle por categoría

### 1. Descubrimiento de hosts (alive/ping)

| Script | Descripción | Uso | Motor |
|---|---|---|---|
| `alive.sh` | Barrido rápido de hosts vivos por ping usando masscan | `sh alive.sh` (lee `ip.txt`) | masscan |
| `alive1.sh` | Envío masivo de ICMP Echo Request con nmap a alta velocidad | `sh alive1.sh` (lee `ip.txt`) | nmap `--min-rate 300` |
| `alive2.sh` | Ping scan estándar de nmap sin resolución de nombres | `sh alive2.sh` (lee `ip.txt`) | nmap `-sn` |
| `alive3.sh` | Barrido de ping secuencial sobre una red /24 fija (`192.168.1.0/24`) | `bash alive3.sh` | `ping` nativo |
| `hostalive.sh` | Comprueba uno a uno "up"/"down" cada IP de `ip.txt` con ping | `bash hostalive.sh` | `ping` nativo |
| `pingscan.sh` | Barrido de ping sobre los últimos 254 hosts de una subred /24 indicada | `sh pingscan.sh 192.168.1` | `ping` nativo |
| `icmp_t8_c0.sh` | Prueba de respuesta a ICMP Echo Request (type 8 code 0) puntual | `sh icmp_t8_c0.sh <IP>` | `nping` + `nmap -PE` |
| `ndisc6.sh` | Prueba de respuesta a Neighbor Discovery (ICMPv6 type 135) en `ipv6.txt` | `sh ndisc6.sh` | `ndisc6` |
| `coincideip.sh` | Calcula la intersección entre `ip.txt` e `ip2.txt` (IPs vivas en ambos escaneos) | `sh coincideip.sh` | POSIX sh puro |

### 2. Escaneo de puertos TCP/UDP

| Script | Descripción | Uso | Motor |
|---|---|---|---|
| `scan.sh` | **Script principal** de la suite: escaneo de puertos con nmap sobre `ip.txt`, genera `resultado.txt` | `./scan.sh` | nmap |
| `scan2.sh` | Recorre los 65535 puertos invocando `scanpuerto` puerto a puerto | `bash scan2.sh` | wrapper de `scanpuerto` |
| `scan3.sh` | Escaneo SYN+versión rápido al puerto 80, filtra solo abiertos | `sh scan3.sh <IP>` | nmap `-sS -sV -T5` |
| `scan` (sin ext.) | Escaneo de todos los puertos (1-65535) con banner grabbing | `./scan <IP>` | `pwncat` |
| `scan.ps1` | Escáner de puertos multihilo para rangos IPv4 privados con informe HTML, compatible PowerShell 5 | `./scan.ps1` (Windows) | PowerShell runspaces |
| `scanport.sh` | Escanea el listado `ip.txt` con nmap (uso genérico) | `bash scanport.sh` | nmap |
| `scanpuerto` | Escaneo rápido masivo con `masscan` sobre `todas.txt` (hasta ~100.000 hosts/hora, ~50% fiabilidad) | `sh scanpuerto` | masscan |
| `scanpuerto1` | Igual que `scanpuerto` pero usando `zmap` como motor | `sh scanpuerto1` | zmap |
| `scanpuerto2` | Escaneo rápido de puertos/servicios sobre IP, rango o FQDN | `sh scanpuerto2 <objetivo>` | nmap |
| `scanpuertoipv6` | Escaneo masivo de un puerto concreto sobre `ipv6.txt` (masscan + nmap) | `sh scanpuertoipv6 <puerto>` | masscan + nmap |
| `scanpuertoudp` | Escaneo UDP de un puerto concreto sobre `todas.txt` | `sh scanpuertoudp <puerto>` | nmap `-sU` |
| `scantcp` | Escáner TCP simple de todos los puertos con Netcat | `./scantcp <IP>` | `nc -z -r` |
| `scantcp2` | Escáner TCP de los 65535 puertos usando `/dev/tcp` de Bash en paralelo | `bash scantcp2 <IP>` | Bash puro (sin dependencias) |
| `telnetscan` | Escaneo de puertos TCP mediante conexiones telnet secuenciales | `bash telnetscan <IP>` | `telnet` |
| `telnetscan.sh` | Variante que prueba el puerto 80 en un rango /24 fijo vía telnet | `bash telnetscan.sh` | `telnet` |
| `ncatscan.bat` | Escáner de puertos secuencial para MS-DOS/Windows con Ncat | `ncatscan.bat <IP>` | `ncat` |
| `scantelnet.bat` / `telnetscan.bat` | Escaneo de puertos vía telnet.exe para entornos Windows/MS-DOS | `telnetscan.bat <IP>` | `telnet.exe` + `netstat` |

### 3. IPv6

| Script | Descripción | Uso | Motor |
|---|---|---|---|
| `scanipv6.sh` | Escaneo rápido del puerto 22 sobre un bloque IPv6 global (`2a02:9000::/23`) | `sh scanipv6.sh` | nmap `-6 --min-rate 9999` |
| `scanipv6local.sh` | Descubre vecinos IPv6 link-local en la LAN (ping multicast `ff02::1`) y escanea puertos | `sh scanipv6local.sh` | `ping6` + nmap `-6` |
| `mac2linklocal.sh` | Calcula la dirección IPv6 link-local (`fe80::/10`) a partir de una MAC | `sh mac2linklocal.sh 00:11:22:aa:bb:cc` | cálculo EUI-64 en Bash |
| `rastreador6.sh` | Traceroute masivo sobre `ipv6.txt`, extrae IPv6 de las rutas encontradas | `sh rastreador6.sh` | `traceroute -6` |

> Ver también [`ipv6.md`](ipv6.md): guía de referencia sobre direccionamiento IPv4 vs IPv6, tipos de direcciones (unicast, multicast, anycast, link-local) y cálculo de prefijos.

### 4. Firewalls, IDS y evasión

| Script | Descripción | Uso | Motor |
|---|---|---|---|
| `firewall.sh` | Detecta puertos filtrados por ACL/firewall sobre un objetivo puntual (`unfiltered` = filtrado con RST) | `./firewall.sh <objetivo>` | nmap `-F --open` |
| `firewall2.sh` | Igual que `firewall.sh` pero de forma masiva sobre `ip.txt`, con scripts NSE `firewall-bypass`, `http-waf-fingerprint`, `http-waf-detect` | `bash firewall2.sh` | nmap `-sACV -O` |
| `tcpwrapped.sh` | Escaneo agresivo completo (`-A`) para confirmar respuestas `tcpwrapped` | `sh tcpwrapped.sh <IP>` | nmap `-A` |
| `ocultaversionSO.sh` | Referencia informativa de valores TTL por sistema operativo para dificultar el fingerprinting | `sh ocultaversionSO.sh` | informativo (no escanea) |

### 5. Escaneo web y servicios específicos

| Script | Descripción | Uso | Motor |
|---|---|---|---|
| `iis.sh` | Escáner rápido de vulnerabilidades/fingerprint en servidores IIS/ASP.NET sobre un rango CIDR | `./iis.sh 192.168.0.0/24` | nmap NSE `http-server-header`, `http-headers`, `http-title` |
| `nodejs.sh` | Detecta servicios Node.js expuestos en puertos habituales (3000, 8080, 1337…) | `sh nodejs.sh <objetivo>` | nmap NSE `http-headers`, `http-devframework` |
| `hsts.sh` | Comprueba si la cabecera HSTS (`Strict-Transport-Security`) está activa en `dominios.txt` | `bash hsts.sh` | `curl` |
| `http.sh` | Chequea la respuesta HTTP/2 de cada host en `ip.txt` (requiere `MyRootCA.crt`) | `./http.sh` | `curl --http2-prior-knowledge` |
| `httpstatus.sh` | Consulta el código de estado HTTP de cada FQDN en `dominios.txt` | `bash httpstatus.sh` | `curl -I` |
| `scanwebserver.sh` | Escaneo de banners sobre un listado extenso de puertos web habituales (80, 8080, 8443, paneles cPanel/Plesk…) | `bash scanwebserver.sh <objetivo>` | nmap NSE `banner` |
| `ip2dominio.sh` | Extrae el/los dominio(s) del certificado TLS (SAN) de una IP o rango | `sh ip2dominio.sh <IP/rango>` | nmap NSE `ssl-cert` |

### 6. Detección de proxies abiertos

| Script | Descripción | Uso | Motor |
|---|---|---|---|
| `openproxy.sh` | Comprueba proxies HTTP abiertos en el puerto 8081 de `proxy.txt`, con cabeceras de navegador simuladas | `bash openproxy.sh` | `curl -x http://` |
| `openproxy0.sh` | Igual, probando HTTP/HTTPS/SOCKS4/SOCKS5 en el puerto 1080 | `bash openproxy0.sh` | `curl -x` (multi-protocolo) |
| `openproxy2.sh` | Igual que `openproxy0.sh` pero forzando SOCKS5 con cabeceras completas de navegador | `bash openproxy2.sh` | `curl -x socks5://` |
| `proxyopen.sh` | Escaneo de proxies HTTP/SOCKS abiertos sobre un objetivo con NSE | `sh proxyopen.sh <objetivo>` | nmap NSE `http-open-proxy`, `socks-open-proxy` |

### 7. Vulnerabilidades y CVE

| Script | Descripción | Uso | Motor |
|---|---|---|---|
| `vuln.sh` | Menú/banner de escaneo de puertos, servicios y vulnerabilidades conocidas sobre un objetivo | `sh vuln.sh <objetivo>` | nmap NSE |
| `vuln2.sh` | Consulta vulnerabilidades conocidas por IP contra la base de datos de Shodan/nrich | `bash vuln2.sh` (lee `ip.txt`) | `nrich` + `jq` |
| `vscan.sh` | Ejecuta un script NSE concreto contra una IP/puerto y resalta hallazgos `VULNERABLE` | `sh vscan.sh <script_nse> <IP> [puerto]` | nmap `--script` |
| `cve.sh` | Instala/actualiza los motores NSE de CVE (`nmap-vulners`, referencias a `vulscan`, `CVEScannerV2`) | `sh cve.sh` | git + nmap NSE |
| `cve-db.sh` | Descarga el feed JSON de CVE recientes del NVD y lo importa a una base de datos SQLite local | `sh cve-db.sh` | `curl` + `jq` + `sqlite3` |
| `freevulnsearch.nse` | Script NSE que consulta vulnerabilidades conocidas por CPE contra una API externa | usado vía `nmap --script freevulnsearch` | NSE (Lua) |
| `vulners.nse` | Script NSE que imprime CVE conocidas asociadas al CPE detectado por `-sV` | `nmap -sV --script vulners <objetivo>` | NSE (Lua) |

### 8. Información de IP / ASN / geolocalización

| Script | Descripción | Uso | Motor |
|---|---|---|---|
| `mi-ip.sh` | Obtiene la IP pública propia (IPv4 e IPv6) | `sh mi-ip.sh` | `curl ifconfig.io` |
| `miip` | Muestra IP pública, interfaces locales y gateway | `./miip` | `wget` + `ifconfig` + `route` |
| `miip2` | Banner ASCII de bienvenida de la suite (sin lógica de red) | `./miip2` | informativo |
| `miip3` | Lista las interfaces de red disponibles para nmap | `./miip3` | `nmap -iflist` |
| `miip4` | Muestra dispositivos de red, hora NTP e IP pública | `./miip4` | `nmcli` + `curl` |
| `ip2bgp` | Consulta el AS (Sistema Autónomo) al que pertenece una IP pública | `./ip2bgp <IP>` | `ip-api.com` |
| `ip2pais` | Consulta el país de origen de una IP pública | `./ip2pais <IP>` | `ip-api.com` |
| `bgp2ip` | Obtiene los rangos IPv4/IPv6 anunciados por un número de AS | `./bgp2ip <AS>` | `whois.radb.net` |

### 9. Traceroute y rutas

| Script | Descripción | Uso | Motor |
|---|---|---|---|
| `trace` | Traceroute con salida extendida y nombres de host | `sh trace <IP>` | `mtr -e -b -rw` |
| `trace.sh` | Traceroute sobre todas las IPs de `ip.txt` | `sh trace.sh` | `traceroute -A -n -d` |
| `trace1.sh` | Monitor de traceroute: detecta cambios de ruta respecto a ejecuciones previas (colores) | `sh trace1.sh` | `traceroute` + diff |
| `trace2.sh` | Traceroute masivo sobre `ip.txt` usando `mtr` | `sh trace2.sh` | `mtr -n -z -rw` |
| `rastreador.sh` | Traceroute sobre `ip.txt`, extrae y depura las IP de cada salto | `sh rastreador.sh` | `traceroute` + `grep`/`awk` |
| `tracebgp` | Traceroute mostrando el AS de cada salto de la ruta | `bash tracebgp <host>` | `traceroute -A` |

### 10. Sistema, monitorización y procesos en local

| Script | Descripción | Uso | Motor |
|---|---|---|---|
| `local.sh` | Muestra puertos abiertos en el equipo local (sockets, procesos, conexiones) — ejecutable remoto vía `curl \| bash` | `bash local.sh` | `ss`, `netstat`, `lsof` |
| `scanlocal.sh` | Versión mínima de `local.sh`: sockets y procesos en escucha | `bash scanlocal.sh` | `ss`, `netstat`, `lsof` |
| `sistema.sh` | Detección de sistema operativo y versión de un objetivo, con tabla resumen IP → SO | `sh sistema.sh <IP>` | nmap `-O --osscan-guess` |
| `sistema2.sh` | Variante de `sistema.sh` (mismo propósito) | `sh sistema2.sh <IP>` | nmap `-O` |
| `so.sh` | Detección de SO/kernel combinada con escaneo de puertos rápido (`-F`) y tabla resumen | `sh so.sh <IP>` | nmap `-F -O --osscan-guess` |
| `alarma.sh` | Monitor de conectividad a Internet (ping continuo a `8.8.8.8`) con aviso sonoro si cae | `bash alarma.sh` | `ping` en bucle |
| `monitor6.sh` | Igual que `alarma.sh` pero monitorizando conectividad IPv6 (`google.es`) | `bash monitor6.sh` | `ping6` en bucle |
| `proceso.sh` | Lanza un escaneo TCP en segundo plano y genera informe HTML (`informe.htm`) | `nohup ./proceso.sh <IP> &` | nmap en background |
| `proceso1.sh` | Variante POSIX sh de `proceso.sh` | `nohup sh proceso1.sh <IP> &` | nmap en background |
| `proceso2.sh` | Igual que `proceso.sh` pero para escaneo UDP (`informe2.htm`) | `nohup ./proceso2.sh <IP> &` | nmap `-sU` en background |
| `proceso3.sh` / `proceso4.sh` | Variantes adicionales de escaneo TCP en background (`informe3.htm`) | `nohup ./proceso3.sh <IP> &` | nmap en background |
| `reparardisco.sh` | Comprueba bloques defectuosos del disco `/dev/sda` en modo solo lectura | `sudo bash reparardisco.sh` | `badblocks -n` (no destructivo) |

### 11. Utilidades varias

| Script/Fichero | Descripción | Uso |
|---|---|---|
| `depura.sh` | Extrae direcciones IPv4 válidas de `resultado.txt` y elimina duplicados → `resultado2.txt` | `sh depura.sh` |
| `resolver.sh` | Resuelve una lista de subdominios (`subdominios.txt`) a IP mediante `host` | `bash resolver.sh` |
| `txt2pdf.sh` | Convierte `resultado.txt` a PDF usando AsciiDoc | `sh txt2pdf.sh` |
| `instalar.sh` | Instalador de dependencias y utilidades de la suite (ver [Instalación](#-instalación)) | `sudo bash instalar.sh` |
| `update.sh` | Descarga la última versión de `scan.sh` desde GitHub | `bash update.sh` |
| `version` | Fichero con la versión actual de la suite | — |

---

## 🎯 Tablas de puertos de referencia

Listados de puertos usados internamente por varios scripts (`scan.sh`, `scanwebserver.sh`, `firewall.sh`…):

| Categoría | Puertos |
|---|---|
| **Top 20 TCP (fast)** | 21,22,23,25,53,80,139,389,443,554,445,631,966,1023,1723,1080,3389,5900,8080,8443,10000 |
| **Top Telnet** | 23,2323,85,70,5001,8000,8023,8083,10000,10001 |
| **Top SSH** | 22,23,26,80,221,222,443,1022,1024,2020,2022,2211,2222,2223,2233,2332,3001,4022,4118,4433,4444,5000,5001,5222,5555,6666,7102,7777,8022,8080,9000,9022,10000,10001,10022,20000,22022,22222,30022,50000 |
| **Top VPN** | 500,943,1194,1197,1500,1701,1723,4500,51820 |
| **Top Backdoor** | 944,4444,1337,31337,8081,12345,54321,60001,47145,27017,11211,20000,32764,49152,65535 |
| **Top PostgreSQL/MySQL** | 5432,5433,1433,3306,106 |
| **Top Citrix** | 80,135,443,1494,2598,7229,8008,8080,9095 |
| **Top WebSocket** | 8080,8443,3000,8089,2222,4444,3001,9090,8765 |
| **Top Fortinet** | 10443,5411,443,4433,8443,4443,444,9443,7443,1723,6443,8009,10000,55443,9000,8081,8880,8889,9001 |
| **Top WEB (extenso)** | 80,443,6443,8080,8834,10000,20000,2222,7000,9009,7443,2087,2096,8443,12443,4100,2082,2083,2086,9000,2052,9001,9002,7001,8188,8089,8189,8082,8084,8085,8010,2078,2080,2079,2053,2095,4000,5200,8888,9443,5000,8087,84,85,86,88,10125,9003,7071,8383,7547,3434,10443,3004,81,4567,7081,82,444,1935,3000,9998,4431,4443,83,90,8001,8099,300,591,593,832,981,1010,1311,2400,3128,3333,4243,4711,4612,4993,5104,5108,6543,7396,7474,8014,8042,8069,8118,8123,8172,8222,8243,8280,8281,8333,8500,8880,8983,9043,9060,9080,9091,9200,9800,9981,16000,18091,18092,20720,28017 |
| **Top Comunes (general)** | 21,22,80,110,111,113,123,137,138,139,143,179,443,445,500,646,1025,1158,1194,1195,1521,1630,1723,3306,3389,3938,4500,5432,5433,5520,5540,5560,5600,5601,5620,5900,8000,8001,8080,9200,10000,11111,1234,12345,20000,22222,27017,30000,33333,40000,44444,50000,55555,65535 |

---

## 📚 Documentación adicional

- [`ipv6.md`](ipv6.md) — Guía de referencia IPv4 vs IPv6: tipos de direcciones, cálculo de prefijos, ejemplos de direccionamiento Dual Stack y enlaces a calculadoras de subredes.

---

## 📜 Licencia

Este proyecto se distribuye bajo licencia [**GPL-3.0**](LICENSE).

---

## 👤 Autor

**Antonio Taboada** ([@hackyseguridad](https://x.com/hackyseguridad) / [@antonio_taboada](https://x.com/antonio_taboada))
🌐 [www.hackingyseguridad.com](http://www.hackingyseguridad.com/)
