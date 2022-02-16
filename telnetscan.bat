@echo off
echo "*** Telnet Scan v1.0 hackingyseguridad.com para MS-DOS***"
echo "Uso.: c:/>telnetscan.bat IP"
set /a puerto=0
:inicio
set /a puerto=%puerto%+1
taskkill /im telnet.exe /f >NUL 2>&1 &
echo "probando puerto :" %puerto% & start /b telnet.exe -f port%puerto%.txt %1 %puerto%
REM timeout 3 /nobreak 
goto inicio
exit
