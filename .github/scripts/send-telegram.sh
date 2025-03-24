send_telegram() {
  local status="$1"
  local message="$2"

  # Escape MarkdownV2 special characters
  escape_markdown() {
    echo "$1" | sed -E 's/([_*\[\]()~`>#+\-=|{}.!])/\\\1/g'
  }

  # Escape both status and message
  status_escaped=$(escape_markdown "$status")
  message_escaped=$(escape_markdown "$message")

  payload=$(jq -n \
    --arg chat_id "${TELEGRAM__CHATID}" \
    --arg status "$status_escaped" \
    --arg message "$message_escaped" \
    '{
      chat_id: $chat_id,
      parse_mode: "MarkdownV2",
      text: ($status + "\n" + $message)
    }')

  # Optional: log the payload (for debug)
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
