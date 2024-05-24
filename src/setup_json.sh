#!/bin/bash

SA_API_ENDPOINT="https://api.sermonaudio.com/v2/node/sermons"

extractHour() {
  # Extract hour using substring
  time_slot=${OUTPUTFILENAME:11:2}

  # Validate the hour format
  if [[ $time_slot =~ ^[0-2][0-9]$ && ${OUTPUTFILENAME:13:1} == "-" ]]; then
    echo "$time_slot"
  else
    # Extract hour using stat if format is invalid
    time_slot=$(stat -c %y "$OUTPUTFILENAMEFULL" | awk '{print substr($2, 1, 2)}')
    echo "$time_slot"
  fi
}

setup_json() {
  # Extract the hour using the helper function
  time_slot=$(extractHour)
  
  # Determine whether the service is AM or PM based on extracted hour
  SERVICE_TYPE=""
  if [[ $time_slot -ge $START_AM && $time_slot -le $END_AM ]]; then
    SERVICE_TYPE="am"
    SERVICE="AM Service"
  elif [[ $time_slot -ge $START_PM && $time_slot -le $END_PM ]]; then
    SERVICE_TYPE="pm"
    SERVICE="PM Service"
  else
    echo "Time does not match AM or PM service windows."
    return 1
  fi

  echo "The time slot is $time_slot"

  # Define file paths based on service type
  JSON="$JSONDATA_PATH/${SERVICE_TYPE}-data.json"
  YTJSON="$JSONDATA_PATH/${SERVICE_TYPE}-yt-data.json"
  SAJSON="$JSONDATA_PATH/${SERVICE_TYPE}-sa-data.json"

  # Fetch sermon ID
  SERMONID=$(curl -s --location "$SA_API_ENDPOINT" \
    --header "X-API-Key: $API_KEY" \
    --header "Content-Type: application/json" \
    --data "@$SAJSON" | jq -r ".sermonID")

  # Extract values from JSON files
  SPEAKER=$(jq -r ".speaker" "$JSON")
  TITLE=$(jq -r ".title" "$JSON")
  SERIES=$(jq -r ".series" "$JSON")
  SA_DATE=$(jq -r ".preachDate" "$SAJSON")
  DATE=$(jq -r ".date" "$JSON")
}
