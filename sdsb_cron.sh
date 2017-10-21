#!/bin/bash

exec 3<<<"" # Create a deleted temporary fil: /dev/fd/3

. sdsb_lib.sh

read_config

bash sdsb_run.sh 2>&1 | tee /dev/fd/3

send_notification /dev/fd/3
