#!/bin/bash

exec 3<<<"" # Create a deleted temporary file: /dev/fd/3

if [ -n "$SDSB_PATH" ];
then
	cd $SDSB_PATH
fi

. sdsb_lib.sh

read_config

/bin/bash sdsb_run.sh 2>&1 | /usr/bin/tee /dev/fd/3

send_notification /dev/fd/3
