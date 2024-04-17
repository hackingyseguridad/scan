wget -4 https://github.com/scmanjarrez/CVEScannerV2/blob/master/cvescannerv2.nse
sudo apt-get install lua5.1; sudo apt-get install lua-sql-sqlite3
nmap -sV 192.168.1.1  --script=cvescannerv2.nse -F
