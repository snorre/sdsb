#!/bin/bash

echo
echo "**************************************"
echo "* SDSB - SuperDuperSimpleBackup v0.1 *"
echo "**************************************"

set -e # stop on first error

. $SDSB_PATH/sdsb_lib.sh

echo
echo "*** Checking directories ***"
check_local_dir $DIRECTORY_TO_BACKUP
check_remote_dir $REMOTE_DATA_ROOT
check_remote_dir $REMOTE_SNAPSHOT_ROOT


echo
echo "*** Uploading data ***"
rsync \
	--archive \
	--verbose \
	--copy-links \
	--bwlimit=$BANDWIDTH_LIMIT_KBS \
	--human-readable \
	--delete \
	--force \
	-e ssh \
	$DIRECTORY_TO_BACKUP/ \
	$SSH_USERNAME@$REMOTE_SERVER:$REMOTE_DATA_ROOT


echo
echo "*** Creating remote snapshot ***"
subpath="$(date +%Y/%m/%d)"
snapshot_name="$(date +%H%M%S)"
ssh $SSH_USERNAME@$REMOTE_SERVER \
	sudo mkdir -p $REMOTE_SNAPSHOT_ROOT/$subpath

ssh $SSH_USERNAME@$REMOTE_SERVER \
	sudo \
	btrfs subvolume snapshot -r \
	$REMOTE_DATA_ROOT \
	$REMOTE_SNAPSHOT_ROOT/$subpath/$snapshot_name


echo
echo "*** Listing remote snapshots ***"
ssh $SSH_USERNAME@$REMOTE_SERVER \
	sudo \
	btrfs subvolume list $REMOTE_SNAPSHOT_ROOT


echo
echo "*** Disk usage ***"
ssh $SSH_USERNAME@$REMOTE_SERVER df -h


echo
echo "*** Backup complete ***"
echo

