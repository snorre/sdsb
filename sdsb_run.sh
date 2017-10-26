#!/bin/bash

echo
echo "**************************************"
echo "* SDSB - SuperDuperSimpleBackup v0.1 *"
echo "**************************************"

set -e # stop on first error

if [ -z "$SDSB_PATH" ];
then
	echo "Setting SDSB_PATH to current directory"
	SDSB_PATH="."
fi

. $SDSB_PATH/sdsb_lib.sh

read_config
print_config

echo
echo "*** Checking directories ***"
check_local_dir $local_data_root
check_remote_dir $remote_data_root
check_remote_dir $remote_snapshot_root


echo
echo "*** Uploading data ***"
/usr/bin/rsync \
	--archive \
	--verbose \
	--copy-links \
	--bwlimit=$bandwidth_limit_KBs \
	--human-readable \
	--delete \
	--force \
	-e ssh \
	$local_data_root/ \
	$ssh_username@$remote_server:$remote_data_root


echo
echo "*** Creating remote snapshot ***"
subpath="$(date +%Y/%m/%d)"
snapshot_name="$(date +%H%M%S)"
/usr/bin/ssh $ssh_username@$remote_server \
	sudo mkdir -p $remote_snapshot_root/$subpath

/usr/bin/ssh $ssh_username@$remote_server \
	sudo \
	btrfs subvolume snapshot -r \
	$remote_data_root \
	$remote_snapshot_root/$subpath/$snapshot_name


echo
echo "*** Listing remote snapshots ***"
/usr/bin/ssh $ssh_username@$remote_server \
	sudo \
	btrfs subvolume list $remote_snapshot_root


echo
echo "*** Disk usage ***"
echo "Backup root: "
/usr/bin/ssh $ssh_username@$remote_server\
	df -h $remote_data_root
echo "Snapshot root: "
/usr/bin/ssh $ssh_username@$remote_server\
	df -h $remote_snapshot_root


echo
echo "*** Done ***"
echo

