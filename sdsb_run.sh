#!/bin/bash

echo
echo "**************************************"
echo "* SDSB - SuperDuperSimpleBackup v0.1 *"
echo "**************************************"

set -e # stop on first error

. sdsb_lib.sh

read_config
print_config

echo
echo "*** Checking directories ***"
check_local_dir $local_data_root
check_remote_dir $remote_data_root
check_remote_dir $remote_snapshot_root


echo
echo "*** Uploading data ***"
rsync \
	--archive \
	--verbose \
	--copy-links \
	--bwlimit=$bandwidth_limit_KBs \
	--human-readable \
	--delete \
	--force \
	-e ssh \
	$local_data_root/ $remote_server:$remote_data_root


echo
echo "*** Creating remote snapshot ***"
subpath="$(date +%Y/%m/%d)"
snapshot_name="$(date +%H%M%S)"
ssh $remote_server \
	sudo mkdir -p $remote_snapshot_root/$subpath

ssh $remote_server \
	sudo \
	btrfs subvolume snapshot -r \
	$remote_data_root \
	$remote_snapshot_root/$subpath/$snapshot_name


echo
echo "*** Listing remote snapshots ***"
ssh $remote_server \
	sudo \
	btrfs subvolume list $remote_snapshot_root


echo
echo "*** Disk usage ***"
echo "Backup root: "
ssh $remote_server\
	df -h $remote_data_root
echo "Snapshot root: "
ssh $remote_server\
	df -h $remote_snapshot_root


echo
echo "*** Done ***"
echo

