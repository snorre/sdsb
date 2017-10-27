#!/bin/bash

exec 3<<<"" # Create a deleted temporary file: /dev/fd/3

. $SDSB_PATH/sdsb_lib.sh

bash $SDSB_PATH/sdsb_run.sh 2>&1 | tee /dev/fd/3

echo
echo "*** Sending notification ***"
send_notification /dev/fd/3
