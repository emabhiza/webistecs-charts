#!/bin/bash
send_telegram() {
  local status="$1"
  local message="$2"

  # Properly escape JSON values
  status_escaped=$(jq -Rs . <<< "$status" | sed 's/^"//;s/"$//')
  message_escaped=$(jq -Rs . <<< "$message" | sed 's/^"//;s/"$//')

  payload=$(jq -n \
    --arg chat_id "${TELEGRAM__CHATID}" \
    --arg status "$status_escaped" \
    --arg message "$message_escaped" \
    '{
      chat_id: $chat_id,
      parse_mode: "HTML",
      text: ($status + "\n" + $message)
    }')

  response=$(curl -s -X POST "https://api.telegram.org/bot${TELEGRAM__TOKEN}/sendMessage" \
    -H "Content-Type: application/json" \
    -d "$payload")

  if ! echo "$response" | jq -e '.ok' >/dev/null; then
    echo "Telegram API Error:" >&2
    echo "$response" | jq . >&2
    return 1
  fi
}