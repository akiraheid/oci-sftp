#!/bin/sh
set -e

function createUser() {
	username=$1
	if [ -z "$username" ]; then
		echo "Username can't be empty"
		exit 1
	fi

	homeDir=/home/$username
	chrootDir=/share/home/$username
	mkdir -p $chrootDir $homeDir/.ssh
	adduser -h $homeDir -S $username
	chown -R $username:$username $chrootDir $homeDir
	chmod 744 $chrootDir
	chmod 700 $homeDir
	passwd -u $username

	# Set up user keys
	keysDir=/keys/$username
	cat $keysDir/authorized_keys > $homeDir/.ssh/authorized_keys
}

while getopts ":u:" opt; do
    case $opt in
    	u)
			username=$OPTARG
			createUser "$username"
    		echo "Added user $username"
    		;;
		\?)
    		echo "Invalid option: -$OPTARG"
    		exit 1
    		;;
    	:)
    		echo "Option -$OPTARG requires an argument."
    		exit 1
    		;;
	esac
done
ionice -c 3 /usr/sbin/sshd -D -e
