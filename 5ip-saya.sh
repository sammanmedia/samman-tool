#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"
LOGDIR="$DIR/log"
LOGFILE="$LOGDIR/Ip-saya.txt"

# Buat folder Log kalau belum ada
mkdir -p "$LOGDIR"

# Ambil IP PRIVATE
PRIVATE_IP=$(hostname -I | awk '{print $1}')

# Ambil data dari API
DATA=$(curl -s "http://ip-api.com/json/?fields=status,query,isp,as,country,city,lat,lon,proxy")

PUBLIC_IP=$(echo "$DATA" | grep -oP '"query":"\K[^"]+')
ISP=$(echo "$DATA" | grep -oP '"isp":"\K[^"]+')
ASN=$(echo "$DATA" | grep -oP '"as":"\K[^"]+')
CITY=$(echo "$DATA" | grep -oP '"city":"\K[^"]+')
COUNTRY=$(echo "$DATA" | grep -oP '"country":"\K[^"]+')
LAT=$(echo "$DATA" | grep -oP '"lat":\K[^,]+')
LON=$(echo "$DATA" | grep -oP '"lon":\K[^,]+')
PROXY_STAT=$(echo "$DATA" | grep -oP '"proxy":\K[^,]+' | tr -d '[:space:]')

# Konversi proxy true/false jadi Iya / Tidak
if [[ "$PROXY_STAT" == "true" ]]; then
    PROXY="Iya"
else
    PROXY="Tidak"
fi

# Link Maps
MAPS="https://www.google.com/maps?q=$LAT,$LON"

# Ambil kode negara untuk flag (optional, default ID)
FLAG="🌍"
if [[ "$COUNTRY" == "Indonesia" ]]; then
    FLAG="🇮🇩"
elif [[ "$COUNTRY" == "United States" ]]; then
    FLAG="🇺🇸"
elif [[ "$COUNTRY" == "Singapore" ]]; then
    FLAG="🇸🇬"
fi

# Tulis ke log (overwrite)
cat > "$LOGFILE" <<EOF
====== MY IP =====

IP PUBLIC   : $PUBLIC_IP
IP PRIVATE  : $PRIVATE_IP
ISP         : $ISP
ASN         : $ASN
NEGARA      : $COUNTRY
KOTA        : $CITY
LOKASI      : $LAT , $LON
GOOGLE MAPS : $MAPS
PROXY       : $PROXY
BENDERA     : $FLAG
EOF


# Teks untuk dialog
TEXT="
====== MY IP =====

IP PUBLIC   : $PUBLIC_IP
IP PRIVATE  : $PRIVATE_IP
ISP         : $ISP
ASN         : $ASN
NEGARA      : $COUNTRY
KOTA        : $CITY
LOKASI      : $LAT , $LON
GOOGLE MAPS : $MAPS
PROXY       : $PROXY
BENDERA     : $FLAG

LOG DISIMPAN DI:
$LOGFILE
"

# Tampilkan Ncurses (msgbox biasa)
dialog --clear \
       --backtitle "IP CHECKER - by Samman" \
       --title "INFORMASI IP ANDA" \
       --ok-label "< KEMBALI" \
       --msgbox "$TEXT" 22 70

# Kembali ke menu
clear
bash "$DIR/menu.sh"
