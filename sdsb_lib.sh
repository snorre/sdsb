function read_config {
	local config_file="sdsb_config.sh"
	if test ! -r $config_file;
	then
		echo ""
		echo "Configuration file is missing."
		echo "Create a file called '$config_file' next to this script that contains:"
		echo ""
		echo 'local_data_root="/path/to/data/that/needs/backing/up"'
		echo 'remote_server="remote.server.com"'
		echo 'remote_data_root="/path/to/backed/up/data"'
		echo 'remote_snapshot_root="/path/to/btrfs/snapshots"'
		echo 'bandwidth_limit_KBs=1000'
		echo 'sendgrid_api_key="MY_API_KEY'
		echo 'notification_email="me@some.domain"'
		echo ""

		exit 1
	fi

	. $config_file
}

function print_config {
	echo
	echo "*** Configuration ***"
	echo "Local folder: $local_data_root"
	echo "Remote server: $remote_server"
	echo "Remote backup root: $remote_data_root"
	echo "Remote snapshot root: $remote_snapshot_root"
	echo "Bandwidth limit KB/s: $bandwidth_limit_KBs"
	echo "Sendgrid API Key: $(echo $sendgrid_api_key | head -c 10)..."
	echo "Notification email: $notification_email"
}

function check_remote_dir {
	echo -n "Checking remote $1.. "

	if ssh $remote_server test ! -d $1;
	then
		echo "Missing, exiting"
		exit 1
	fi

	if ssh $remote_server test ! -w $1;
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
						\"email\": \"$notification_email\"
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
		-H "Authorization: Bearer $sendgrid_api_key" \
		-H "Content-Type: application/json" \
		-d "$post_data"
}
