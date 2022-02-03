@echo off
echo "*** Telnet Scan v1.0 hackingyseguridad.com para MS-DOS ***"
set /a puerto=0
:inicio
set /a puerto=%puerto%+1
echo "Probando puerto :" %puerto%
telnet $1 %puerto% & sleep 3
goto inicio
exit
