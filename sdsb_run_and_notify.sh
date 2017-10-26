#!/bin/bash

exec 3<<<"" # Create a deleted temporary file: /dev/fd/3

if [ -z "$SDSB_PATH" ];
then
	echo "Setting SDSB_PATH to current directory"
	SDSB_PATH="."
fi

. $SDSB_PATH/sdsb_lib.sh

read_config

/bin/bash $SDSB_PATH/sdsb_run.sh 2>&1 | /usr/bin/tee /dev/fd/3

send_notification /dev/fd/3
