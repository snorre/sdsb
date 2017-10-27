# TODO
run_on_remote="ssh $SSH_USERNAME@$REMOTE_SERVER"

function check_remote_dir {
	echo -n "Checking remote $1.. "

	if ssh $SSH_USERNAME@$REMOTE_SERVER test ! -d $1;
	then
		echo "Missing, exiting"
		exit 1
	fi

	if ssh $SSH_USERNAME@$REMOTE_SERVER test ! -w $1;
	then
		echo "Not writable, exiting."
		exit 1
	fi

	echo "Ok"
}

function check_local_dir {
	echo -n "Checking local $1.. "

	if test ! -d $1;
	then
		echo "Missing, exiting"
		exit 1
	fi

	echo "Ok"
}

function send_notification {
	local file_base64=$(base64 -w 0 $1)
	local post_data="
	{
		\"personalizations\": [
			{
				\"to\": [
	        			{
						\"email\": \"$NOTIFICATION_EMAIL\"
	 				}
				],
				\"subject\": \"SDSB backup report\"
			}
		],
		\"from\": {
			\"email\": \"sdsb@$(hostname)\"
		},
		\"content\": [
			{
				\"type\": \"text/plain\",
				\"value\": \"See attached file.\"
			}
		],
		\"attachments\": [
			{
				\"content\": \"$file_base64\",
				\"type\": \"text/plain\",
				\"filename\": \"logfile.txt\"
			}
		]
	}"

	curl \
		-X "POST" \
		"https://api.sendgrid.com/v3/mail/send" \
		-H "Authorization: Bearer $SENDGRID_API_KEY" \
		-H "Content-Type: application/json" \
		-d "$post_data"
}
