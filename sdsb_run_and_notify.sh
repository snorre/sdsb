#!/bin/bash

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


exec 3<<<"" # Create a deleted temporary file: /dev/fd/3

bash $SDSB_PATH/sdsb_run.sh 2>&1 | tee /dev/fd/3

echo
echo "*** Sending notification ***"
send_notification /dev/fd/3
