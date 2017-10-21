#!/bin/bash

. sdsb_lib.sh

read_config

bash sdsb_run.sh &> sdsb.log

send_notification sdsb.log

#rm sdsb.log
