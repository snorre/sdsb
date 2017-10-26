#!/bin/bash

# Write SDSB config file
rm -f $SDSB_PATH/sdsb_config.sh
echo "local_data_root='/data-to-backup'" >> $SDSB_PATH/sdsb_config.sh
echo "remote_server='$REMOTE_SERVER'" >> $SDSB_PATH/sdsb_config.sh
echo "remote_data_root='$REMOTE_DATA_ROOT'" >> $SDSB_PATH/sdsb_config.sh
echo "remote_snapshot_root='$REMOTE_SNAPSHOT_ROOT'" >> $SDSB_PATH/sdsb_config.sh
echo "bandwidth_limit_KBs=$BANDWIDTH_LIMIT_KBS" >> $SDSB_PATH/sdsb_config.sh
echo "sendgrid_api_key='$SENDGRID_API_KEY'" >> $SDSB_PATH/sdsb_config.sh
echo "notification_email='$NOTIFICATION_EMAIL'" >> $SDSB_PATH/sdsb_config.sh
echo "ssh_username='$SSH_USERNAME'" >> $SDSB_PATH/sdsb_config.sh
