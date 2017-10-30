#!/bin/bash

function run_on_remote {
	ssh $SSH_USERNAME@$REMOTE_SERVER $@
}

function check_remote_dir {
	echo -n "Checking remote $1.. "

	if run_on_remote test ! -d $1;
	then
		echo "Missing, exiting"
		exit 1
	fi

	if run_on_remote test ! -w $1;
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


echo
echo "**************************************"
echo "* SDSB - SuperDuperSimpleBackup v0.1 *"
echo "**************************************"

set -e # stop on first error

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
run_on_remote \
	sudo mkdir -p $REMOTE_SNAPSHOT_ROOT/$subpath

run_on_remote \
	sudo \
	btrfs subvolume snapshot -r \
	$REMOTE_DATA_ROOT \
	$REMOTE_SNAPSHOT_ROOT/$subpath/$snapshot_name


echo
echo "*** Listing remote snapshots ***"
run_on_remote \
	sudo \
	btrfs subvolume list $REMOTE_SNAPSHOT_ROOT


echo
echo "*** Disk usage ***"
run_on_remote df -h


echo
echo "*** Backup complete ***"
echo

