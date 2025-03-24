#!/bin/bash
send_telegram() {
  local status="$1"
  local message="$2"

  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM__TOKEN}/sendMessage" \
    -H "Content-Type: application/json" \
    -d '{
      "chat_id": "'"${TELEGRAM__CHATID}"'",
      "parse_mode": "HTML",
      "text": "'"$status\n$message"'"
    }'
}
