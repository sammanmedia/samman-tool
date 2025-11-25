#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")"

# Harus root
if [ "$EUID" -ne 0 ]; then
    dialog --msgbox "Jalankan dengan: sudo bash samba-auto-mount.sh" 8 45
    clear
    exit 1
fi

# ================== INPUT IP ==================
IP=$(dialog --cancel-label "Kembali" \
            --inputbox "Masukkan IP Samba Server" 8 40 2>&1 >/dev/tty)

if [ $? -ne 0 ] || [ -z "$IP" ]; then
    clear
    exec bash "$DIR/menu.sh"
fi

BASE_DIR="/mnt/samba-$IP"
DESKTOP="/home/$(logname)/Desktop"
SHORTCUT="$DESKTOP/SAMBA-$IP"

# ================== PILIHAN ==================
CHOICE=$(dialog --clear \
    --ok-label "Pilih" \
    --cancel-label "Kembali" \
    --menu "Pilih aksi untuk IP : $IP" 12 45 3 \
    1 "MOUNT" \
    2 "UNMOUNT" \
    3 "KEMBALI" \
    2>&1 >/dev/tty)

if [ $? -ne 0 ] || [ "$CHOICE" = "3" ]; then
    clear
    exec bash "$DIR/menu.sh"
fi


# ====================================================
# ===================== MODE UNMOUNT =================
# ====================================================
if [ "$CHOICE" = "2" ]; then

    if [ ! -d "$BASE_DIR" ]; then
        dialog --yesno "❌ Folder $BASE_DIR tidak ditemukan.\n\nBelum pernah di-mount?\n\nKembali ke menu?" \
        10 50 --yes-label "Ya" --no-label "Keluar"

        if [ $? -eq 0 ]; then
            clear
            exec bash "$DIR/menu.sh"
        else
            clear
            exit
        fi
    fi

    # Unmount semua folder
    for MOUNT in $(mount | grep "$BASE_DIR" | awk '{print $3}'); do
        umount -f "$MOUNT" 2>/dev/null
    done

    # Hapus folder mount
    rm -rf "$BASE_DIR"

    # Hapus shortcut desktop
    rm -f "$SHORTCUT"

    dialog --yesno "✅ UNMOUNT BERHASIL\n\n$BASE_DIR telah dihapus\nShortcut di Desktop terhapus" \
    10 55 --yes-label "Kembali" --no-label "Keluar"

    if [ $? -eq 0 ]; then
        clear
        exec bash "$DIR/menu.sh"
    else
        clear
        exit
    fi
fi


# ====================================================
# ===================== MODE MOUNT ===================
# ====================================================

# Input Username
USER=$(dialog --cancel-label "Kembali" \
              --inputbox "Masukkan Username Samba" 8 40 2>&1 >/dev/tty)

if [ $? -ne 0 ]; then
    clear
    exec bash "$DIR/menu.sh"
fi

# Input Password
PASS=$(dialog --cancel-label "Kembali" \
              --insecure --passwordbox "Masukkan Password Samba" 8 40 2>&1 >/dev/tty)

if [ $? -ne 0 ]; then
    clear
    exec bash "$DIR/menu.sh"
fi

mkdir -p "$BASE_DIR"

# Ambil daftar share
SHARES=$(smbclient -L //$IP -U "$USER%$PASS" 2>/dev/null | awk '/Disk/{print $1}')

if [ -z "$SHARES" ]; then

    dialog --yesno "❌ LOGIN GAGAL atau SHARE tidak ditemukan\n\nIP : $IP" \
    10 50 --yes-label "Kembali" --no-label "Keluar"

    if [ $? -eq 0 ]; then
        clear
        exec bash "$DIR/menu.sh"
    else
        clear
        exit
    fi
fi

COUNT=0

for SHARE in $SHARES; do

    MOUNT_DIR="$BASE_DIR/$SHARE"
    mkdir -p "$MOUNT_DIR"

    mount -t cifs "//$IP/$SHARE" "$MOUNT_DIR" \
    -o username="$USER",password="$PASS",iocharset=utf8,vers=3.0,noperm 2>/dev/null

    if mount | grep -q "$MOUNT_DIR"; then
        COUNT=$((COUNT+1))
    else
        rmdir "$MOUNT_DIR" 2>/dev/null
    fi

done

# Buat shortcut Desktop
if [ -d "$DESKTOP" ]; then
    ln -sf "$BASE_DIR" "$SHORTCUT"
fi

# Hasil
dialog --yesno "✅ BERHASIL\n\n$COUNT folder SHARE berhasil di-mount\n\nLokasi:\n$BASE_DIR\n\nShortcut: Desktop" \
10 60 --yes-label "Kembali" --no-label "Keluar"

if [ $? -eq 0 ]; then
    clear
    exec bash "$DIR/menu.sh"
else
    clear
    exit
fi
