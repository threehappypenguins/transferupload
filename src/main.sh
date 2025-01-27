#!/bin/bash

# Source the .env file with variable definitions
if [ -f /etc/transferupload/.env ]; then
    source /etc/transferupload/.env
else
    echo "Error: .env file not found. Exiting main.sh." >&2
    exit 1
fi

source $HOME_PATH/transferupload/src/setup_json.sh
source $HOME_PATH/transferupload/src/mailer.sh
source $HOME_PATH/transferupload/src/uploader.sh
source $HOME_PATH/transferupload/src/metadata.sh

# Ensure that the file sent is an MP4
FILENAME='.*\.[mM][pP]4'
# The following is if the filename needs
# to be with the following format: YYYY-MM-DD_hh-mm-ss.mp4
#FILENAME=[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}\.*\.mp4

/usr/bin/inotifywait \
  --recursive \
  --monitor \
  --quiet \
  -e moved_to \
  -e close_write \
  --format '%w%f' \
  --includei "$FILENAME" \
  "$WATCH_DIR" \
| while read -r INPUT_FILE; do

  echo "Transfer stopped. Checking if ${INPUT_FILE} is complete:"
YYYY=$(stat --format='%y' "$INPUT_FILE" | cut -d'-' -f1)
OUTPUT=$(MP4Box -info "$INPUT_FILE" 2>&1)

# Send mail regarding completion of file transfer
mailer

echo "Done sending mail."

if [[ ${OUTPUT} == *"Movie Info"* ]]; then
  # Move the completed file to the Sermon Archive.
  INPUT_BASE=$(basename "$INPUT_FILE")
  OUTPUTFILENAMEFULL="$ARCHIVE_PATH/$YYYY/$INPUT_BASE"
  mv "${INPUT_FILE}" "${OUTPUTFILENAMEFULL}"
  echo "Done moving file to ${OUTPUTFILENAMEFULL}."
  OUTPUTFILENAME=$(basename "$OUTPUTFILENAMEFULL")
  NEWOUTPUT=$(MP4Box -info $OUTPUTFILENAMEFULL 2>&1)
  echo "This is the new filename: $OUTPUTFILENAME"
else
  continue
fi

# Establish which json files to use
setup_json

# When the transfer is complete, attempt to upload the mp4 by
# checking if json exists:
if [[ ! -f $JSON ]]; then
  echo "No json file found. Not uploading; not adding metadata. Please manually upload and add metadata."
  continue
elif [[ ${NEWOUTPUT} != *"Movie Info"* ]]; then
  continue
fi

{ 
 echo "Uploading to Sermon Audio..."
 SAuploader & \
 echo "Uploading to YouTube..." & \
 YTuploader;
} 2>&1

echo "Done uploading."
echo "Checking for when Sermon Audio is finished processing the video..."

while true; do
  SAprocessorwatch
  if [[ $? -eq 0 ]]; then

    echo "Sermon Audio video finished processing. Sending mail..."
    SAmailer

    echo "Done sending mail."

    echo "Publishing..."
    publishSA

    echo "Published."

    break
  fi
  sleep .5
done

echo "Adding metadata and renaming mp4, and deleting json files..."
metadata

echo "Done adding metadata, renaming mp4, and deleting json files."
echo "Finished."

done
