#!/bin/bash

metadata() {
  HOME="${HOME:-/home/crpc}" # defines the home folder where a configuration file resides

  # Extract time zone
  TZ=$(stat -c %y $OUTPUTFILENAMEFULL | awk '{print $NF}')

  # Extract month
  MM=${DATE:5:2}

  # Extract day
  DD=${DATE:8:2}

  # This function defines the hour, minute, and second of the mp4
  # file. If the time format in the filename is not met, then it
  # defaults to extracting the time from the modified date
  extractTime() {
    # Extracting values using substring
    hh=${OUTPUTFILENAME:11:2}
    mm=${OUTPUTFILENAME:14:2}
    ss=${OUTPUTFILENAME:17:2}

    # Checking conditions in the filename
    if [[ $hh =~ ^[0-2][0-9]$ && \
          ${OUTPUTFILENAME:13:1} == "-" && \
          $mm =~ ^[0-5][0-9]$ && \
          ${OUTPUTFILENAME:16:1} == "-" && \
          $ss =~ ^[0-5][0-9]$ ]]; then
        echo "Extracted from filename. Hour:$hh, minute: $mm, second: $ss"
    else
        # Extracting values using stat and awk
        hh=$(stat -c %y "$OUTPUTFILENAMEFULL" | awk '{print substr($2, 1, 2)}')
        mm=$(stat -c %y "$OUTPUTFILENAMEFULL" | awk '{print substr($2, 4, 2)}')
        ss=$(stat -c %y "$OUTPUTFILENAMEFULL" | awk '{print substr($2, 7, 2)}')
        echo "Extracted from file's modified stamp. Hour:$hh, minute: $mm, second: $ss"
    fi
  }

  # Extract time using the function
  extractTime

  case $SERVICE in
    *"AM Service"*)
      service="AM"
    ;;

    *"PM Service"*)
      service="PM"
    ;;
  esac

  if [[ $SPEAKER != *$MINISTER* ]];
  then
    guestspeaker=" ($SPEAKER)"
  else
    guestspeaker=""
  fi

  if [[ $SERIES = *$SERIES_OTHER1* ]];
  then
    SERIES=$SERIES_OTHER1_FN
  else
    SERIES=$SERIES
  fi

  if [[ $SERIES = *$SERIES_AM* ]];
  then
    series=$SERIES_FN_AM
  fi

  if [[ $SERIES = *$SERIES_PM* ]];
  then
    series=$SERIES_FN_PM
  fi

  if [[ $SERIES = *$SERIES_OTHER2* ]];
  then
    series=$SERIES_OTHER2_FN
  fi

  if [[ $SERIES = *$SERIES_OTHER3* ]];
  then
    series=$SERIES_OTHER3_FN
  fi

  if [[ $SERIES = *$SERIES_OTHER4* ]];
  then
    series=$SERIES_OTHER4_FN
  fi

  if [[ $SERIES = *$SERIES_OTHER5* ]];
  then
    series=$SERIES_OTHER5_FN
  fi

  # Remove ? and : and / from the title for filename renaming
  filetitle=$(echo "$TITLE" | sed -r 's/[:]+/-/g; s/[?\/]//g')

  # Add metadata tags to MP4
  AtomicParsley $OUTPUTFILENAMEFULL \
  --albumArtist="$SPEAKER" \
  --title="$TITLE" \
  --album="$SERIES" \
  --genre=Sermons \
  --year=$YYYY \
  --output=$ARCHIVE_PATH/$YYYY/temp.mp4

  # Add date and time, and rename MP4
  exiftool \
  -config $HOME_PATH/.ExifTool_config \
  -progress -P \
  -overwrite_original \
  -Filename="$ARCHIVE_PATH/$YYYY/$YYYY$MM$DD$service$series$filetitle$guestspeaker.mp4" \
  -FileModifyDate="$YYYY:$MM:$DD $hh:$mm:$ss$TZ" \
  -AllDates="$YYYY:$MM:$DD $hh:$mm:$ss$TZ" \
  -MediaCreateDate="$YYYY:$MM:$DD $hh:$mm:$ss$TZ" \
  -MediaModifyDate="$YYYY:$MM:$DD $hh:$mm:$ss$TZ" \
  $ARCHIVE_PATH/$YYYY/temp.mp4

  # Print final MP4 filename and show info
  FINAL=$(MP4Box -info "$ARCHIVE_PATH/$YYYY/$YYYY$MM$DD$service$series$filetitle$guestspeaker.mp4" 2>&1)

  # This checks to make sure there is no corruption in the MP4
  if [[ $FINAL != *"Movie Info"* ]];
  then
    echo "Something is wrong. There is no complete, final, and renamed mp4 file."
    exit 1
  fi

  echo "Removing ${JSON##*/}, ${SAJSON##*/} & ${YTJSON##*/} & ${OUTPUTFILENAME}"
  rm $JSON $SAJSON $YTJSON
  rm "$OUTPUTFILENAMEFULL"
}
