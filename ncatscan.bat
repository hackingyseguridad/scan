@echo off
echo "*** Ncat Scan v1.0 hackingyseguridad.com para MS-DOS***"
echo "Uso.: c:/>telnetscan.bat IP"
set /a puerto=0
:inicio
set /a puerto=%puerto%+1
echo "Probando puerto TCP :" %puerto%
ncat -zv %1 %puerto%
goto inicio
exit
