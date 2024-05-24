mailer () {
  case $OUTPUT in
	*"Incomplete"*)
		echo "${OUTPUT}"
		SUBJECT="Transfer Interrupted"
		MSG="The mp4 transfer for ${INPUT_FILE} was interrupted and did not complete."
	;;

	*"Movie Info"*)
		echo "${OUTPUT}"
		SUBJECT="Transfer Complete"
		MSG="The mp4 transfer for ${INPUT_FILE} is complete."
	;;

	*)
		echo "${OUTPUT}"
		SUBJECT="Check on Transfer"
		MSG="Something could be wrong with ${INPUT_FILE}. Manually check the mp4."
	;;
  esac

  HTML="<pre style=\"white-space: pre-wrap; word-break: keep-all; \
                    background-color: whitesmoke;\"><code>${OUTPUT}</code></pre>"

  echo -e "\nSending mail...\n"

/usr/sbin/sendmail -t <<-EOF
	From: $FROM_EMAIL
	To: $TO_EMAIL
	Subject: $SUBJECT
	Content-Type: text/html
	MIME-Version: 1.0

	$MSG The output is as follows:

	$HTML
EOF
}

SAmailer() {
/usr/sbin/sendmail -t <<-EOF
	From: $FROM_EMAIL
	To: $TO_EMAIL
	Subject: SA Video Finished
	Content-Type: text/html
	MIME-Version: 1.0

	The Sermon Audio video is finished processing.
EOF
}