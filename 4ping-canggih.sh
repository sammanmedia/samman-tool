#!/bin/bash

BOT_TOKEN="8567116861:AAGOVSfSeHiD9dJxC2X-Y63aCKUs3jkLTrQ"
CHAT_ID="8463837263"

IP_RANGE=$(whiptail --inputbox "Masukkan IP Range (contoh: 192.168.0.1-255)" 10 60 3>&1 1>&2 2>&3)

BASE_IP=$(echo "$IP_RANGE" | cut -d'.' -f1-3)
START=$(echo "$IP_RANGE" | cut -d'.' -f4 | cut -d'-' -f1)
END=$(echo "$IP_RANGE" | cut -d'-' -f2)

LOG="log/lan_report_$(date +%Y%m%d_%H%M%S).txt"

echo "Scan LAN: $IP_RANGE" > "$LOG"
echo "=============================" >> "$LOG"
echo -e "Komputer | Status | Hostname | Ping" >> "$LOG"
echo "-----------------------------------" >> "$LOG"

# --- SCAN CEPAT: cari IP yang hidup saja ---
ALIVE_IPS=$(fping -a -g $BASE_IP.$START $BASE_IP.$END 2>/dev/null)

for IP in $ALIVE_IPS; do
    PING_TIME=$(ping -c 1 -W 1 "$IP" | grep 'time=' | awk -F'time=' '{print $2}' | awk '{print $1}')
    HOST=$(nmblookup -A "$IP" 2>/dev/null | grep "<00>" | awk '{print $1}')

    [ -z "$HOST" ] && HOST="Unknown"
    [ -z "$PING_TIME" ] && PING_TIME="N/A"

    echo -e "$IP\t[UP]\t$HOST\t$PING_TIME" | tee -a "$LOG"
done

echo "" >> "$LOG"
echo "=============================" >> "$LOG"
echo "PING CANGGIH V1+TELEBOT" >> "$LOG"

curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
    --data-urlencode chat_id="$CHAT_ID" \
    --data-urlencode parse_mode="Markdown" \
    --data-urlencode text="$(cat $LOG)"

whiptail --title "PING CANGGIH" --msgbox "Selesai! Cepat + Hostname sudah tepat. Log sudah dikirim ke Telegram." 10 60