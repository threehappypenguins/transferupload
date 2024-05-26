#!/bin/bash

YTuploader() {
  # YouTube Uploader secrets and token
  CLIENTSECRETS="$YTUPLOADER_CSRT/client_secrets.json"
  REQUESTTOKEN="$YTUPLOADER_CSRT/request.token"

  youtubeuploader -filename $ARCHIVE_PATH/$YYYY/$OUTPUTFILENAME \
  -secrets $CLIENTSECRETS \
  -cache $REQUESTTOKEN \
  -metaJSON $YTJSON;
}

# UPLOADING A SERMON USING THE SERMONAUDIO API V2.
SAuploader() {
     # The file you want to upload.
     MEDIA_DIR=$ARCHIVE_PATH/$YYYY
     MEDIA_FILENAME=$OUTPUTFILENAME
     MEDIA_PATH="${MEDIA_DIR}/${MEDIA_FILENAME}"

     ENDPOINT="https://api.sermonaudio.com/v2/media"

     JSON="{
     \"sermonID\": \"${SERMONID}\",
     \"uploadType\": \"original-video\",
     \"originalFilename\": \"${MEDIA_FILENAME}\"
     }
     "

     # First, post to the media endpoint to create a media upload for the
     # sermon. Part of the response will be the URL to which you upload the
     # media.
     #
     # We need to capture the output from posting to the endpoint. In a
     # shell script, that's kind of clumsy. I'm using a Python snippet to
     # get the field we need out of the JSON response. In a programming
     # language, this would be much simpler.

     UPLOAD_RESPONSE=$(
          curl -s \
               -H "X-API-Key: ${API_KEY}" \
               -H "Content-Type: application/json" \
               -X POST \
               -d "$JSON" \
               $ENDPOINT
               )

     GET_URL_SNIPPET='
import json
import sys

try:
    response = json.loads(sys.stdin.read())
    print(response["uploadURL"])
except json.JSONDecodeError as e:
    print(f"JSONDecodeError: {e}")
    print(f"Invalid JSON response: {sys.stdin.read()}")
except KeyError as e:
    print(f"KeyError: {e}")
    print(f"Response JSON: {response}")
'

     URL=$(echo $UPLOAD_RESPONSE | python -c "$GET_URL_SNIPPET" )

     echo $URL

     # Must use wget and not curl to upload, because of the file size limits on curl
     wget --header "X-API-Key: ${API_KEY}" --verbose --post-file $MEDIA_PATH $URL

     # curl command that doesn't work with large files
     # curl --progress-bar \
     #      -H "X-API-Key: ${API_KEY}" \
     #      -X POST \
     #      --data-binary "$MEDIA_PATH" \
     #      $URL \
     #      |& cat
}

SAprocessorwatch() {
  curljson=$(curl -s -H "X-Api-Key: ${API_KEY}" "https://api.sermonaudio.com/v2/node/sermons/$SERMONID?allowUnpublished=True" | jq -r '.media.video[].videoCodec')
  sleep 1m
  echo $curljson
  if [[ $curljson =~ "h264" ]]; then
    return 0  # Indicate that the condition was met
  else
    return 1  # Indicate that the condition was not met
  fi
}

publishSA() {
  PUBLISHJSON="{
\"publishDate\": \"${SA_DATE}\"
}
"
    curl -v \
     --header "X-API-Key: ${API_KEY}" \
     -H "Content-Type: application/json" \
     -X PATCH \
     -d "$PUBLISHJSON" \
     "https://api.sermonaudio.com/v2/node/sermons/${SERMONID}" \
    | python -mjson.tool
}