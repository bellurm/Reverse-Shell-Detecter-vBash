#!/bin/bash

function listen(){
    read -p "What is your local IP address: " ipAddress

    read -p "Port number to listen: " portNumber

    read -p "Interface name to listen: " iface

    while true
    do
        # TCP bağlantıları dinlenecek
        tcpdump -i $iface -n -s 0 -v src $ipAddress and dst port $portNumber -w /tmp/tcpdump.pcap &
        # tcpdump 5 saniye boyunca çalışacak
        sleep 5
        # tcpdump sonlandırılacak
        kill $!
        # .pcap dosyasında filtreleme işlemi yapılacak
        tcpdump -nn -r /tmp/tcpdump.pcap | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort | uniq | while read ip
        do
            # Eğer bir reverse shell bağlantısı tespit edilirse bildirim gönderilecek
            notify-send "WARNING" \
            "[!!!] Reverse Shell detected! > $ip" \
            -t 20000        
        done
        # İşlemler bittikten sonra .pcap dosyası silinecek.
        sudo rm -f /tmp/tcpdump.pcap
    done
}

if [ $(whoami) != "root" ]
then
    echo "[INFO] You have to be 'root'."
else
    listen
fi