#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")"

while true; do
    dialog --clear --backtitle "Aplikasi Tool By Samman" \
        --title "REDME" \
        --ok-label "KEMBALI" \
        --cancel-label "KELUAR" \
        --help-button --help-label "README" \
        --extra-button --extra-label "INFO" \
        --msgbox $'
        Nama       : Samman

Sosial Media:
- Facebook : https://facebook.com/guntur1994
- YouTube  : https://www.youtube.com/@sammanmedia
- Instagram: https://www.instagram.com/sammangrup

Follow Bot Telegram
- @sammanmedia_bot


Terima kasih sudah menggunakan Tool ini!
Gratis Dan boleh di modifikasi' 15 60

    RESPONSE=$?
    clear

    case $RESPONSE in
        0)  # KEMBALI
            exec bash "$DIR/menu.sh"
            ;;
        1)  # KELUAR
            echo "┌───────────────[di Buat Oleh Samman]───────────────┐"
            echo "│   Terima kasih sudah memakai tool ini            │"
            echo "└───────────────────────────────────────────────────┘"
            exit 0
            ;;
        2)  # REDME
            dialog --msgbox "Readme :\n- Versi 1.0\n- Dibuat oleh Samman\nTool Wajib Install :\n1) apt install fping \n2) apt install htop \n3) apt install gnome-terminal \n4) apt install sudo apt install samba-common net-tools whiptail cifs-utils" 10 50
            ;;
        3)  # INFO
            dialog --msgbox "Petunjuk Penggunaan:\n- Gunakan tombol KANAN / KIRI / ATAS / BAWAH\n- Tekan ENTER untuk OK" 12 60
            ;;
    esac
done
