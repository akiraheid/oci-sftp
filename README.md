An SFTP-only server.

Features:
* Users get their own directory in `/share/home/`.
	* Users can upload to their user directory.
	* User directories are read-only to other users.
* Local, read-only filesystem mount to `/share/`.
	* Host can share read-only files to users.
* Users are chrooted to `/share/`.

# Configuration

This container requires the following directory structure:
```text
sftp/
|_server/
| |_ssh_host_ed25519_key
| |_ssh_host_ed25519_key.pub
| |_ssh_host_rsa_key
| |_ssh_host_rsa_key.pub
| |_sshd_config
|_users/
| |_user1/authorized_keys
| |_...
|_readonly/
  |_...

```
## Generate server keys

Generate keys for the server.

```bash
ssh-keygen -t ed25519 -f server/ssh_host_ed25519_key < /dev/null
ssh-keygen -t rsa -b 4096 -f server/ssh_host_rsa_key < /dev/null
```

These keys will be mounted to the container.

## Create authorized users

Create user authorized key files. Only public key authentication is enabled.

```text
users/
|_user1/authorized_keys
|_user2/authorized_keys

```

SSH keys can be added to the `authorized_keys` file via command line.

```bash
cat id_rsa.pub | xargs echo >> user1/authorized_keys
```

These users are created at runtime with the keys loaded into the container user's `/home/user/.ssh/`.

## Readonly files

Files in `readonly/` will be visible and read-only to all users.

# Usage

```bash
podman run \
	-d \
	--name sftp \
	-p 2222:22 \
	--rm \
	-v ${PWD}/readonly/:/share/ \
	-v ${PWD}/server/:/server/:ro \
	-v ${PWD}/users/:/users/:ro \
	-v sftpUsers:/share/home/ \
	sftp
```
