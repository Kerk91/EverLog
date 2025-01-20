#!/bin/bash

# Log file location
LOG_FILE="/var/log/login_post_request.log"

# API endpoint Head over to https://portal.stabilityprotocol.com/keys to generate your own API key
API_URL="https://rpc.stabilityprotocol.com/zkt/try-it-out"

EXPLORER_URL="https://stability.blockscout.com/tx/"

# Write start message to log
USER=$PAM_USER
IP_ADDRESS=$PAM_RHOST
SERVICE=$PAM_SERVICE
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SESSION_TYPE=$PAM_TYPE
#Give your server a server ID
SERVERID=888

#Change your secure password
PASS=YourSecurePassword

#Update to your own encryption method
#ENCRYPTION_COMMAND="openssl enc -aes-256-cbc -a -A -salt -pass pass:$PASS"

echo "$(date): Triggered login_post_request.sh for IP: $IP_ADDRESS" >> $LOG_FILE
EVENT="ServerID:$SERVERID, User: $USER, IP: $IP_ADDRESS, Service: $SERVICE, Timestamp: $TIMESTAMP, SessionType: $SESSION_TYPE"
#EVENT="$(echo "$EVENT" | $ENCRYPTION_COMMAND)"
# Build the JSON payload
PAYLOAD=$(cat <<EOF
{
  "arguments":"$EVENT"
}
EOF
)

# Make the POST request
RESPONSE=$(curl -s -w "HTTP_CODE:%{http_code}" -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

# Extract HTTP status code
HTTP_CODE=$(echo "$RESPONSE" | grep -o 'HTTP_CODE:[0-9]*' | cut -d: -f2)

# Extract the response body
RESPONSE_BODY=$(echo "$RESPONSE" | sed 's/HTTP_CODE:[0-9]*//')

# Log the results
echo "$(date): HTTP Code: $HTTP_CODE" >> "$LOG_FILE"
echo "$(date): Response Body: $RESPONSE_BODY" >> "$LOG_FILE"
# Check if the request succeeded
if [ "$HTTP_CODE" -ne 200 ]; then
    echo "$(date): Error: POST request failed with code $RESPONSE" >> $LOG_FILE
    exit 1
fi
HASH=$(echo $RESPONSE_BODY \
  | grep -o '"hash":"[^"]*"' \
  | sed -E 's/"hash":"([^"]*)"/\1/')

# Success message
echo "$(date): POST request succeeded for IP: $IP_ADDRESS" >> $LOG_FILE
echo "$(date): POST response: $RESPONSE" >> $LOG_FILE
echo "$(date): URL: $EXPLORER_URL$HASH" >> $LOG_FILE
echo "$(date): Transaction URL: $EXPLORER_URL$HASH" 

exit 0


