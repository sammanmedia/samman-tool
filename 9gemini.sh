



#!/bin/bash

# ==========================
# Gemini CLI Chat (Loop)
# CTRL + C untuk keluar
# ==========================

API_KEY="AIzaSyC5QQ42WcA7UgoMe4LuBuoUs4jOUaZW0W4"
MODEL="gemini-2.5-flash-lite"

# Warna ANSI
YELLOW="\033[1;33m"
RESET="\033[0m"

# Trap CTRL+C
trap 'echo -e "\nKeluar dari Gemini CLI 👋"; exit 0' INT

echo "=== Gemini CLI Chat ==="
echo "Tekan CTRL + C untuk keluar"
echo ""

while true; do
  read -p "Gemini> " PROMPT

  RESPONSE=$(curl -s \
    -H "Content-Type: application/json" \
    "https://generativelanguage.googleapis.com/v1beta/models/$MODEL:generateContent?key=$API_KEY" \
    -d "{\"contents\":[{\"parts\":[{\"text\":\"$PROMPT\"}]}]}")

  ANSWER=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text')

  echo -e "${YELLOW}$ANSWER${RESET}"
  echo ""
done
