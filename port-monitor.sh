#!/bin/bash
SERVER="127.0.0.1"
PORT=443
CHAT_ID="XXX"
TOKEN="XXX"
LOGFILE="./port-downtime-monitor/port-monitor.log"
TMP_STATUS="./port-downtime-monitor/port-monitor-status.txt"
TIMEOUT=5

nc -vz -w $TIMEOUT $SERVER $PORT >/dev/null 2>&1
RESULT=$?

if [ $RESULT -eq 0 ]; then
    STATUS="UP"
else
    STATUS="DOWN"
fi

LAST_STATUS=$(cat "$TMP_STATUS" 2>/dev/null || echo "UNKNOWN")

if [ "$STATUS" = "DOWN" ]; then
    if [ "$LAST_STATUS" = "UP" ]; then
        MESSAGE="⚠️ Server *$SERVER:$PORT* is unavailable!%0A⏰ $(date '+%Y-%m-%d %H:%M:%S')"
        /usr/bin/curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
            -d chat_id="$CHAT_ID" \
            -d text="$MESSAGE" \
            -d parse_mode="Markdown"
    fi
else
    if [ "$LAST_STATUS" = "DOWN" ]; then
        MESSAGE="✅ Server *$SERVER:$PORT* is available.%0A⏰ $(date '+%Y-%m-%d %H:%M:%S')"
        /usr/bin/curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
            -d chat_id="$CHAT_ID" \
            -d text="$MESSAGE" \
            -d parse_mode="Markdown"
    fi
fi

echo "$STATUS" > "$TMP_STATUS"

echo "$(date '+%Y-%m-%d %H:%M:%S') $SERVER:$PORT $STATUS" >> "$LOGFILE"
