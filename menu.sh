#!/bin/bash

# otomatis cari folder tempat menu.sh berada
DIR="$(dirname "$(readlink -f "$0")")"

while true; do
    CHOICE=$(dialog --clear --backtitle "Aplikasi Tool By Samman " \
        --title "Menu Utama" \
        --ok-label "⭕️ JALANKAN" \
        --cancel-label "❌ KELUAR" \
        --help-button --help-label "README" \
        --menu "Pilih Opsi Tool:" 15 60 5 \
        1 "Penghapus Virus + Telegrambot" \
        2 "Penghapus Virus (Single)" \
        3 "Samba Scanner + Log" \
        4 "Ping Canggih + Log" \
        5 "Cek IP Saya + Log" \
        6 "Samba Mount & Unmount" 2>&1 >/dev/tty)

    RESPONSE=$?   # << kode tombol OK, Cancel, Help
    clear

    case $RESPONSE in
        1)  # tombol KELUAR (cancel)
            echo "┌───────────────[di Buat Oleh Samman]───────────────┐"
            echo "│    Terima kasih sudah memakai tool ini            │"
            echo "└───────────────────────────────────────────────────┘"
            exit 0
            ;;
        2)  # tombol README
            exec bash "$DIR/redme.sh"
            ;;
    esac

    # ===== EKSEKUSI MENU =====
    case $CHOICE in
        1)  gnome-terminal -- bash -c "$DIR/1penghapus-virus+tele.sh; exec bash" & ;;
        2)  gnome-terminal -- bash -c "$DIR/2penghapus-virus.sh; exec bash" & ;;
        3)  gnome-terminal -- bash -c "$DIR/3samba.sh; exec bash" & ;;
        4)  gnome-terminal -- bash -c "$DIR/4ping-canggih.sh; exec bash" & ;;
        5)  bash "$DIR/5ip-saya.sh" ;;
        6)  bash "$DIR/6samba-mount.sh" ;;
        7)  gnome-terminal -- bash -c "curl ifconfig.me; echo; read -p 'ENTER untuk keluar...'; exec bash" & ;;
    esac
done
