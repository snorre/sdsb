#!/bin/bash

set -e # stop on first error

#
# Configuration
#
if test ! -r sdsb.config.sh;
then
	echo ""
	echo "Configuration file is missing."
	echo "Create a file called 'sdsb.config.sh' next to this script that contains:"
	echo ""
	echo 'local_data_root="/path/to/data/that/needs/backing/up"'
	echo 'remote_server="remote.server.com"'
	echo 'remote_data_root="/path/to/backed/up/data"'
	echo 'remote_snapshot_root="/path/to/btrfs/snapshots"'
	echo 'bandwidth_limit_KBs=1000'
	echo ""
	
	exit 1
fi

. sdsb.config.sh


echo
echo "**************************************"
echo "* SDSB - SuperDuperSimpleBackup v0.1 *"
echo "**************************************"

echo
echo "*** Configuration ***"
echo "Local folder: $local_data_root"
echo "Remote server: $remote_server"
echo "Remote backup root: $remote_data_root"
echo "Remote snapshot root: $remote_snapshot_root"
echo "Bandwidth limit KB/s: $bandwidth_limit_KBs"

echo
echo "*** Checking directories ***"
function check_remote_dir {
	echo -n "Checking remote $1.. "

	if ssh $remote_server test ! -d $1;
	then
		echo "Missing, exiting"
		exit 1
	fi

	if ssh $remote_server test ! -w $1;
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

check_local_dir $local_data_root
check_remote_dir $remote_data_root
check_remote_dir $remote_snapshot_root


echo
echo "*** Uploading data ***"
function limited_print {
        headlines=5
        taillines=8

        num_lines=$(cat $1 | wc -l)

        if (($num_lines <= ($headlines + $taillines) ));
        then
                cat $1
        else
                head --lines=$headlines $1
                echo "..."
                echo "..."
                tail --lines=$taillines $1
        fi

}

xferlog="rsync_output_$(uuidgen)"

rsync \
	--archive \
	--verbose \
	--copy-links \
	--bwlimit=$bandwidth_limit_KBs \
	--human-readable \
	--delete \
	--force \
	-e ssh \
	$local_data_root/ $remote_server:$remote_data_root \
	1> $xferlog

limited_print $xferlog

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


# TODO send email with attachment
rm $xferlog


echo 
echo "*** Done ***"
echo

