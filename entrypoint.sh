#!/bin/sh
set -e

function createUser() {
	username=$1
	if [ -z "$username" ]; then
		echo "Username can't be empty"
		exit 1
	fi
	echo "Creating user ${username}"

	# Configure user home where SSH information is stored
	# Not accessible to anyone because we chroot all SFTP users to /share
	homeDir=/home/$username
	mkdir -p $homeDir/.ssh
	adduser -h $homeDir -S $username
	addgroup $username
	passwd -u $username

	# Set up user keys
	keysDir=/users/$username
	authKeys=$homeDir/.ssh/authorized_keys
	cat $keysDir/authorized_keys > $authKeys
	chmod 700 $homeDir $homeDir/.ssh
	chmod 600 $authKeys
	chown -R $username:$username $homeDir

	# Configure shared user directory where other users can see their files
	shareDir=/share/home/$username
	mkdir -p $shareDir
	chmod 755 $shareDir
	chown -R $username:$username $shareDir
}

# Loop through users in /keys and create their accounts
function createUsers() {
	cd /users
	file=/users.txt
	ls -d -1 */ > $file
	sed -i "s/\///g" $file

	for i in "$(cat $file)"; do
		createUser $i
	done
	rm $file
}

function configureServer() {
	cp /server/ssh* /etc/ssh/
}

# Script start

chmod 755 /share
configureServer
createUsers
ionice -c 3 /usr/sbin/sshd -D -e
