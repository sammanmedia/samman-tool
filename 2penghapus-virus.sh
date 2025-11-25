#!/bin/bash

clear
echo "===================================================="
echo "   ANTIVIRUS REALTIME by samman (NO LOG VERSION)"
echo "===================================================="
echo ""
read -p "Masukkan lokasi folder (lokal / samba) : " INPUT

# ================== DETEKSI SAMBA ==================
if [[ "$INPUT" == smb://* || "$INPUT" == //* ]]; then

    CLEAN=${INPUT#smb://}
    CLEAN=${CLEAN#//}

    SERVER=$(echo "$CLEAN" | cut -d/ -f1)
    SHARE=$(echo "$CLEAN" | cut -d/ -f2)
    SUBPATH=$(echo "$CLEAN" | cut -d/ -f3-)

    if [ -z "$SERVER" ] || [ -z "$SHARE" ]; then
        echo "❌ Format salah. Contoh: //192.168.60.175/DATA/folder1"
        exit 1
    fi

    read -p "Username Windows (kosong = guest): " USER
    read -s -p "Password: " PASS
    echo ""

    MOUNT_BASE="/mnt/$SHARE"
    sudo mkdir -p "$MOUNT_BASE"

    echo "[*] Mounting //$SERVER/$SHARE → $MOUNT_BASE"

    if [ -z "$USER" ]; then
        sudo mount -t cifs "//$SERVER/$SHARE" "$MOUNT_BASE" -o guest,vers=3.0
    else
        sudo mount -t cifs "//$SERVER/$SHARE" "$MOUNT_BASE" -o username="$USER",password="$PASS",vers=3.0
    fi

    if [ $? -ne 0 ]; then
        echo "❌ Gagal mount samba"
        exit 1
    fi

    if [ -n "$SUBPATH" ]; then
        FOLDER="$MOUNT_BASE/$SUBPATH"
    else
        FOLDER="$MOUNT_BASE"
    fi

# ================== LOKAL ==================
else
    FOLDER="$INPUT"
fi

# ================== VALIDASI ==================
if [ ! -d "$FOLDER" ]; then
    echo "❌ Folder tidak ditemukan: $FOLDER"
    exit 1
fi

EXT=("pif" "vbs" "jar" "exe" "scr" "bat" "js" "cmd" "lnk")

echo ""
echo "===================================================="
echo "Folder dipantau : $FOLDER"
echo "Mode            : TANPA LOG FILE"
echo "Metode          : SMART LOOP (Stabil untuk Samba)"
echo "Tekan CTRL+C untuk STOP"
echo "===================================================="
echo ""

declare -A known_files

# ================== LOOP MONITOR ==================
while true; do

    while IFS= read -r -d '' FILE; do

        if [[ ${known_files["$FILE"]} ]]; then
            continue
        fi

        known_files["$FILE"]=1

        IS_VIRUS=false
        for virus in "${EXT[@]}"; do
            if [[ "${FILE,,}" == *".$virus" ]]; then
                IS_VIRUS=true
                break
            fi
        done

        NOW=$(date "+%T - %d/%m/%Y")

        if [ "$IS_VIRUS" = true ]; then
            chattr -i "$FILE" 2>/dev/null
            chmod 777 "$FILE" 2>/dev/null
            rm -v "$FILE"

            echo -e "\e[31m[ $NOW ] HAPUS VIRUS : $FILE\e[0m"
        else
            echo -e "\e[32m[ $NOW ] AMAN : $FILE\e[0m"
        fi

    done < <(find "$FOLDER" -type f -print0 2>/dev/null)

    sleep 2
done
