#!/usr/bin/env bash

JSONPATH=/path/to/json/files

YYYY=${9:0:4}
MM=${9:5:2}
DD=${9:8:2}
TZ=$(date +%:z)

MONTHS=(ZERO January February March April May June July August September October November December)

descr=${4//, /$'\001'}
descr=${descr//,/$'\n'}
descr=$'\n'"${descr//$'\001'/, }"
sadescr="${descr#"${descr%%[![:space:]]*}"}"

months=${9:5:2}
[ $months -lt 10 ] && months=${months:1};

day=${9:8:2}
[ $day -lt 10 ] && day=${day:1};

if [[ ${8} = *"AM"* ]];
then
  time=$'10:30 am\n' # Change to correct time
  yttime='10:30 am\\n' # Change to correct time
  hhmmss='T10:30:00'
  service='Morning'
fi

if [[ ${8} = *"PM"* ]];
then
  time=$'2:00 pm\n' # Change to correct time
  yttime='2:00 pm\\n' # Change to correct time
  hhmmss='T14:00:00'
  service='Afternoon'
fi

# If it's not the main minister, then there are changes for YouTube
# as well as renaming the file to indicate a guest speaker
if [[ ${7} != *"Rev. MyMinister Name"* ]];
then
  guestspeaker="$7"$'\n'
  ytguestspeaker="$7"
fi

# If it's not the main minister, then there
# are changes for Sermon Audio
if [[ ${7} != *"Rev. John Shearouse"* ]];
then
  saguestspeaker=$'\n'"$7"
else
  saguestspeaker=""
fi

if [[ ${2} = *"?"* ]];
then
  filetitle=${2%?}
else
  filetitle=${2}
fi

if [[ ${6} = *"&"* ]];
then
  sabibleText=$(echo "${6}" | sed 's/\s*\&\s*/; /g')
else
  sabibleText=${6}
fi

ytdescription="$2"'\\n'"${6%%;*}"'\\n'"$day ${MONTHS[$months]} ${9:0:4}, ${yttime}${ytguestspeaker}"

case $8 in
  *"AM"*)
    echo "${8}"
    SADATA=$JSONPATH/am-sa-data.json
    YTDATA=$JSONPATH/am-yt-data.json
    DATA=$JSONPATH/am-data.json
    ytplaylist=$3
    eventcategory="Sunday Service" # This must match Sermon Audio's category
  ;;

  *"PM"*)
    echo "${8}"
    SADATA=$JSONPATH/pm-sa-data.json
    YTDATA=$JSONPATH/pm-yt-data.json
    DATA=$JSONPATH/pm-data.json
    ytplaylist=$3
    eventcategory="Sunday Afternoon" # This must match Sermon Audio's category
  ;;
esac

#YouTube json data
jq -n \
--arg privacy "$1" \
--arg title "$2" \
--arg playlist "$ytplaylist" \
--arg description "$2"$'\n'"${6%%;*}"$'\n'"$day"$' '"${MONTHS[$months]}"$' '"${9:0:4}"$', '"$time""$guestspeaker""$descr" \
--arg recordingdate "${9:0:10}" \
'{ "title": $title,
"description": $description,
"privacyStatus": $privacy,
"embeddable": true,
"categoryId": "29",
"playlistTitles": [$playlist],
"recordingdate": $recordingdate }' \
> $YTDATA

#Sermon Audio json data
jq -n --arg fullTitle "$2" \
--arg shorttitle "$5" \
--arg speakerName "$saspeaker" \
--arg saguestspeaker "$saguestspeaker" \
--arg preachDate "$9" \
--arg series "$saseries" \
--arg bibleText "$sabibleText" \
--arg description "$descr" \
--arg sadescription "$sadescr" \
--arg eventcategory "$eventcategory" \
--arg socialtitle "$2" \
--argjson facebook "$facebook" \
'{
  "acceptCopyright": true,
  "fullTitle": $fullTitle,
  "displayTitle": $shorttitle,
  "speakerName": $speakerName,
  "preachDate": $preachDate,
  "subtitle": $series,
  "bibleText": $bibleText,
  "moreInfoText": $sadescription,
  "eventType": $eventcategory,
  "socialSharing": (
    if $facebook then
      [{
        "platform": "facebook",
        "message": "\"\( $socialtitle )\"\( $saguestspeaker )\n\n\( $sadescription )",
        "useVideoClip": true
      }, {
        "platform": "twitter",
        "message": "\"\( $socialtitle )\"\( $saguestspeaker )",
        "useVideoClip": true
      }]
    else
      [{
        "platform": "facebook",
        "message": "\"\( $socialtitle )\"\( $saguestspeaker )\n\n\( $sadescription )",
        "useVideoClip": true
      }]
    end
  ),
  "social_sharing_video_clip": {
    "start": 0.0,
    "end": 120.0
  }
}' > $SADATA

#Metadata data
jq -n --arg speaker "$7" \
--arg title "$2" \
--arg series "$3" \
--arg date "$9" \
'{ "speaker": $speaker,
"title": $title,
"series": $series,
"date": $date }' \
> $DATA

#Display data
echo -e "\nYoutube Data for ${YTDATA##*/}:\n"
cat ${YTDATA}
echo -e "\nSermon Audio for ${SADATA##*/}:\n"
cat ${SADATA}
echo -e "\nBasic Data for ${DATA##*/}:\n"
cat ${DATA}