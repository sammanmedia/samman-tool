#!/bin/bash

# ================= WARNA =================
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
CYAN='\e[36m'
NC='\e[0m'

LOGFILE="log/Samba_Log.txt"
THREADS=80   # makin besar = makin cepat

# =============== CTRL+C HANDLER =========
trap ctrl_c INT
function ctrl_c() {
    echo -e "\n${RED}Scan dihentikan oleh user (CTRL+C)${NC}"
    kill 0 2>/dev/null
    exit 0
}

# Kosongkan file log setiap mulai scan
> "$LOGFILE"

echo -e "${YELLOW}Masukan IP network (contoh: 192.168.60):${NC}"
read NETWORK

echo ""
echo -e "${YELLOW}Scanning SAMBA server di $NETWORK.1 - $NETWORK.255${NC}"
echo "--------------------------------------------------------------------"
printf "%-12s %-18s %-30s\n" "[STATUS]" "[IP ADDRESS]" "[HOSTNAME / MAC]"
echo "--------------------------------------------------------------------"

TOTAL=255

# ============== FUNCTION SCAN ============
scan_ip() {

    IP=$1

    # Ping agar masuk ARP
    ping -c 1 -W 1 $IP &> /dev/null

    # Cek port 445 (SAMBA)
    timeout 1 bash -c "echo >/dev/tcp/$IP/445" 2>/dev/null

    if [ $? -eq 0 ]; then

        HOSTNAME=$(timeout 2 nmblookup -A $IP 2>/dev/null | grep "<00>" | grep -v "__MSBROWSE__" | head -n 1 | awk '{print $1}')
        MAC=$(ip neigh show $IP | awk '{print $5}')

        [ -z "$HOSTNAME" ] && HOSTNAME="UNKNOWN"
        [ -z "$MAC" ] && MAC="UNKNOWN"

        # Output TERMINAL
        printf "[ ${GREEN}TERBUKA${NC} ] %-18b %-30b\n" \
        "${CYAN}$IP${NC}" \
        "${YELLOW}$HOSTNAME / $MAC${NC}"

        # Output LOG (tanpa warna)
        printf "[ TERBUKA ] %-15s   %-20s   %s\n" "$IP" "$HOSTNAME" "$MAC" >> "$LOGFILE"

    else
        # IP DOWN warna merah
        printf "[ ${RED}DOWN${NC}    ] %-18b %-30s\n" \
        "${RED}$IP${NC}" \
        "-"
    fi
}

# =============== MULTI THREAD ============
for i in $(seq 1 255)
do
    scan_ip "$NETWORK.$i" &

    # Limit thread
    while [ "$(jobs -r | wc -l)" -ge "$THREADS" ]; do
        sleep 0.03
    done
done

wait

echo -e "\n${GREEN}Scan selesai.${NC}"
echo -e "${CYAN}Hasil tersimpan di file: ${YELLOW}$LOGFILE${NC}"
echo -e "${GREEN}Script ini hanya scan — TIDAK melakukan mount ✅${NC}"
