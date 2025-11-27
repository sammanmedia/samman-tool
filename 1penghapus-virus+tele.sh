#!/bin/bash

clear
echo "┌────────────────────────────────────────────────────┐"
echo "│  ANTIVIRUS REALTIME BY SAMMAN SUPPORT TELEGRAMBOT  │"
echo "├────────────────────────────────────────────────────┘"
echo "│"
read -p "│ Masukkan lokasi folder (lokal / samba) : " INPUT
echo "└────────────────────────────────────────────────────┘"

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

else
    FOLDER="$INPUT"
fi


# ================== VALIDASI ==================
if [ ! -d "$FOLDER" ]; then
    echo "❌ Folder tidak ditemukan: $FOLDER"
    exit 1
fi

# ================== NAMA LOG NYA ==================
LOGFILE="$FOLDER/AntiWorm_Log_$(date +%d-%m-%Y).txt"
touch "$LOGFILE"

# ================== FORMAT EKSEKUSI ==================
EXT=("pif" "vbs" "jar" "exe" "scr" "bat" "js" "cmd" "lnk")


# ================== TELEGRAM SETTING ==================
TELEGRAM_TOKEN="TELEGRAM_TOKENMU_DISINI"
CHAT_ID="CHAT_IDMU_DISINI"

send_telegram() {
    MESSAGE="$1"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
         --data-urlencode  chat_id="$CHAT_ID" \
         --data-urlencode  text="$MESSAGE" \
         --data-urlencode  parse_mode="HTML"
}


# TEST KIRIM TELEGRAM
send_telegram "🟢 *Scanner aktif!* Memantau folder: \`$FOLDER\`"


echo ""
echo "┌───────────────────────────────────────────────────┐"
echo "│   Folder dipantau : $FOLDER                       │"
echo "│   Log             : $LOGFILE                      │"
echo "│   Metode          : SMART LOOP(Stabil untuk Samba)│"
echo "│   Tekan CTRL+C untuk STOP                         │"
echo "└───────────────────────────────────────────────────┘"
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
    echo "[ $NOW ] HAPUS VIRUS : $FILE" >> "$LOGFILE"

    # Kirim ke Telegram (AMAN TANPA ERROR!)
    send_telegram "⚠️ Virus Terdeteksi & Dihapus!
    ───[SCANNING REALTIME]─── 
💾 $FILE
⏰ $NOW
📂 $FOLDER
    ───[rs]───"




else

            echo -e "\e[32m[ $NOW ] AMAN : $FILE\e[0m"
            echo "[ $NOW ] AMAN : $FILE" >> "$LOGFILE"
        fi

    done < <(find "$FOLDER" -type f -print0 2>/dev/null)

    sleep 2
done
