#!/bin/bash

RESULT="open_ports.txt"
TEMP="scan.tmp"
LOGDIR="log"
LOGFILE="$LOGDIR/port-scanner.txt"

# Buat folder log jika belum ada
mkdir -p "$LOGDIR"

# Reset file (auto timpa)
> "$RESULT"
> "$LOGFILE"

clear

# ========== INPUT IP ==========
dialog --clear --backtitle "Aplikasi Tool By Samman" \
       --title "PORT SCANNER (NMAP)" \
       --inputbox "Masukkan IP Target:" 8 45 2> "$TEMP"

IP=$(cat "$TEMP")
rm -f "$TEMP"

if [[ -z "$IP" ]]; then
  dialog --msgbox "IP tidak boleh kosong!" 6 35
  bash menu.sh
  exit
fi


# ========== INPUT PORT AWAL ==========
dialog --clear --backtitle "Aplikasi Tool By Samman" \
       --title "PORT AWAL" \
       --inputbox "Masukkan PORT AWAL:" 8 45 2> "$TEMP"

START_PORT=$(cat "$TEMP")
rm -f "$TEMP"


# ========== INPUT PORT AKHIR ==========
dialog --clear --backtitle "Aplikasi Tool By Samman" \
       --title "PORT AKHIR" \
       --inputbox "Masukkan PORT AKHIR:" 8 45 2> "$TEMP"

END_PORT=$(cat "$TEMP")
rm -f "$TEMP"


# ========= VALIDASI =========
if [[ -z "$START_PORT" || -z "$END_PORT" ]]; then
  dialog --msgbox "PORT tidak boleh kosong!" 6 35
  bash menu.sh
  exit
fi

if (( START_PORT > END_PORT )); then
  dialog --msgbox "PORT AWAL harus lebih kecil dari PORT AKHIR!" 7 45
  bash menu.sh
  exit
fi


# ========== HEADER LOG ==========
{
echo "======================================"
echo "   PORT SCAN RESULT"
echo "======================================"
echo "Target     : $IP"
echo "Port Range : $START_PORT - $END_PORT"
echo "Tanggal    : $(date)"
echo "======================================"
echo
} >> "$LOGFILE"



# ========== SCANNING ==========
(
echo 0
echo "# Scanning $IP (Port $START_PORT - $END_PORT)..."

nmap -p "$START_PORT-$END_PORT" -sS -T4 --min-rate=5000 "$IP" | tee "$RESULT" >> "$LOGFILE"

echo 100
echo "# Selesai..."
sleep 1
) | dialog --gauge "Scanning port $START_PORT - $END_PORT ..." 10 70 0


# ========== HASIL ==========
dialog --clear --backtitle "HASIL SCAN" \
       --title "OPEN PORT - $IP" \
       --ok-label "KEMBALI" \
       --textbox "$RESULT" 20 70


# ========== KEMBALI ==========
bash menu.sh
