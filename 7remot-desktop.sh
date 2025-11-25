#!/bin/bash

# ==============================
# Windows Remote via RDP (NCURSES)
# By Samman (revised)
# ==============================

# Kembali ke menu utama
MENU="$HOME/menu.sh"

# Cek dialog
command -v dialog >/dev/null || { echo "Install dialog dulu: sudo apt install dialog"; exit 1; }

# Fungsi cek port
port_open() {
  timeout 2 bash -c "cat < /dev/null > /dev/tcp/$1/$2" 2>/dev/null
}

# Input IP
IP=$(dialog --inputbox "Masukkan IP Address Windows" 8 40 2>&1 >/dev/tty)
[ -z "$IP" ] && exit

# Input PORT
PORT=$(dialog --inputbox "Masukkan Port (default: 3389)" 8 40 3389 2>&1 >/dev/tty)
[ -z "$PORT" ] && PORT=3389

# Input Password
PASS=$(dialog --insecure --passwordbox "Masukkan Password Remote" 8 40 2>&1 >/dev/tty)

# Cek port
if ! port_open "$IP" "$PORT"; then
    CHOICE=$(dialog --menu "❌ GAGAL KONEKSI\n\nPort $PORT tertutup di $IP" 12 50 2 \
    1 "Kembali" \
    2 "Keluar" \
    2>&1 >/dev/tty)

    if [ "$CHOICE" = "1" ]; then
        bash "$0"
    else
        clear
        exit
    fi
fi

# Eksekusi remote RDP
clear
xfreerdp /v:$IP:$PORT /u:Administrator /p:"$PASS" /cert:ignore /dynamic-resolution +clipboard

# Setelah keluar remote
CHOICE=$(dialog --menu "✅ Koneksi Selesai" 10 40 2 \
1 "Kembali" \
2 "Keluar" \
2>&1 >/dev/tty)

if [ "$CHOICE" = "1" ]; then
    [ -f "$MENU" ] && bash "$MENU" || bash "$0"
else
    clear
    exit
fi
