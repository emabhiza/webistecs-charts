send_telegram() {
  local status="$1"
  local message="$2"

  payload=$(jq -n \
    --arg chat_id "${TELEGRAM__CHATID}" \
    --arg text "$status\n$message" \
    '{
      chat_id: $chat_id,
      text: $text
    }')

  echo "Sending Telegram message:"
  echo "$payload" | jq .

  response=$(curl -s -X POST "https://api.telegram.org/bot${TELEGRAM__TOKEN}/sendMessage" \
    -H "Content-Type: application/json" \
    -d "$payload")

  if ! echo "$response" | jq -e '.ok' >/dev/null; then
    echo "Telegram API Error:" >&2
    echo "$response" | jq . >&2
    return 1
  fi
}
